//
//  PriceAlertService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation
import Combine

protocol PriceAlertService {
    func getPriceAlerts() -> AnyPublisher<[PriceAlert], PriceAlertServiceError>
    func setPriceAlert(_ priceAlert: PriceAlertEntity) -> AnyPublisher<PriceAlert, PriceAlertServiceError>
    func deletePriceAlert(by id: String) -> AnyPublisher<PriceAlert, PriceAlertServiceError>
}

final class PriceAlertServiceImpl: BaseBackendService, PriceAlertService {

    // MARK: - Initializers

    convenience init() {
        let baseURL = URL(string: "https://wenmoon-vapor.herokuapp.com/")!
        self.init(baseURL: baseURL)
    }

    func getPriceAlerts() -> AnyPublisher<[PriceAlert], PriceAlertServiceError> {
        do {
            let deviceToken = try fetchDeviceToken()
            return httpClient.get(path: "price-alerts", headers: ["X-Device-ID": deviceToken])
                .decode(type: [PriceAlert].self, decoder: decoder)
                .mapError { [weak self] error in
                    self?.mapToPriceAlertError(error) ?? .unknown
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: mapToPriceAlertError(error)).eraseToAnyPublisher()
        }
    }

    func setPriceAlert(_ priceAlert: PriceAlertEntity) -> AnyPublisher<PriceAlert, PriceAlertServiceError> {
        do {
            let targetPrice = priceAlert.targetPrice?.doubleValue ?? .zero
            let request = PriceAlert(coinId: priceAlert.id,
                                     coinName: priceAlert.name,
                                     targetPrice: targetPrice,
                                     targetDirection: priceAlert.currentPrice < targetPrice ? .above : .below)
            let body = try encoder.encode(request)
            let deviceToken = try fetchDeviceToken()
            return httpClient.post(path: "price-alert", headers: ["X-Device-ID": deviceToken], body: body)
                .decode(type: PriceAlert.self, decoder: decoder)
                .mapError { [weak self] error in
                    self?.mapToPriceAlertError(error) ?? .unknown
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: mapToPriceAlertError(error)).eraseToAnyPublisher()
        }
    }

    func deletePriceAlert(by id: String) -> AnyPublisher<PriceAlert, PriceAlertServiceError> {
        do {
            let deviceToken = try fetchDeviceToken()
            return httpClient.delete(path: "price-alert/\(id)", headers: ["X-Device-ID": deviceToken])
                .decode(type: PriceAlert.self, decoder: decoder)
                .mapError { [weak self] error in
                    self?.mapToPriceAlertError(error) ?? .unknown
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: mapToPriceAlertError(error)).eraseToAnyPublisher()
        }
    }

    private func fetchDeviceToken() throws -> String {
        guard let deviceToken = userDefaultsManager.getObject(forKey: deviceTokenKey, objectType: String.self) else {
            throw PriceAlertServiceError.deviceTokenNotFound(userDefaultsError ?? .unknown)
        }
        return deviceToken
    }

    private func mapToPriceAlertError(_ error: Error) -> PriceAlertServiceError {
        if let error = error as? APIError {
            return .apiError(error)
        } else if let error = error as? UserDefaultsError {
            return .deviceTokenNotFound(error)
        } else {
            return .unknown
        }
    }
}
