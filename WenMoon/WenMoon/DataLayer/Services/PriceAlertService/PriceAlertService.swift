//
//  PriceAlertService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation
import Combine

protocol PriceAlertService {
    func getPriceAlerts(deviceToken: String) -> AnyPublisher<[PriceAlert], APIError>
    func setPriceAlert(for coin: CoinEntity, deviceToken: String) -> AnyPublisher<PriceAlert, APIError>
    func deletePriceAlert(for id: String, deviceToken: String) -> AnyPublisher<PriceAlert, APIError>
}

final class PriceAlertServiceImpl: BaseBackendService, PriceAlertService {

    // MARK: - Initializers

    convenience init() {
        let baseURL = URL(string: "https://wenmoon-vapor.herokuapp.com/")!
        self.init(baseURL: baseURL)
    }

    func getPriceAlerts(deviceToken: String) -> AnyPublisher<[PriceAlert], APIError> {
        httpClient.get(path: "price-alerts", headers: ["X-Device-ID": deviceToken])
            .decode(type: [PriceAlert].self, decoder: decoder)
            .mapError { [weak self] error in
                self?.mapToAPIError(error) ?? .unknown(response: URLResponse())
            }
            .eraseToAnyPublisher()
    }

    func setPriceAlert(for coin: CoinEntity, deviceToken: String) -> AnyPublisher<PriceAlert, APIError> {
        do {
            let targetPrice = coin.targetPrice?.doubleValue ?? .zero
            let request = PriceAlert(coinId: coin.id,
                                     coinName: coin.name,
                                     targetPrice: targetPrice,
                                     targetDirection: coin.currentPrice < targetPrice ? .above : .below)
            let body = try encoder.encode(request)
            return httpClient.post(path: "price-alert", headers: ["X-Device-ID": deviceToken], body: body)
                .decode(type: PriceAlert.self, decoder: decoder)
                .mapError { [weak self] error in
                    self?.mapToAPIError(error) ?? .unknown(response: URLResponse())
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .failedToEncodeBody).eraseToAnyPublisher()
        }
    }

    func deletePriceAlert(for id: String, deviceToken: String) -> AnyPublisher<PriceAlert, APIError> {
        httpClient.delete(path: "price-alert/\(id)", headers: ["X-Device-ID": deviceToken])
            .decode(type: PriceAlert.self, decoder: decoder)
            .mapError { [weak self] error in
                self?.mapToAPIError(error) ?? .unknown(response: URLResponse())
            }
            .eraseToAnyPublisher()
    }
}
