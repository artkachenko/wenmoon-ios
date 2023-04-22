//
//  PriceAlertListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import CoreData

final class PriceAlertListViewModel: ObservableObject {

    // MARK: - Properties

    @Published var priceAlerts: [PriceAlert] = []
    @Published var errorMessage: String?
    @Published var showErrorAlert = false

    private let context: NSManagedObjectContext

    // MARK: - Initializers

    convenience init() {
        self.init(context: PersistenceManager.shared.container.viewContext)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Methods

    func fetchPriceAlerts() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \PriceAlert.id, ascending: true)]
        let request = PriceAlert.fetchRequest(sortDescriptors: sortDescriptors)
        do {
            let priceAlerts = try context.fetch(request)
            self.priceAlerts = priceAlerts
        } catch {
            configureError(.failedToFetchEntities(error: error as NSError))
        }
    }

    func savePriceAlert(_ coin: Coin) {
        if !priceAlerts.contains(where: { $0.id == coin.id }) {
            _ = PriceAlert(coin: coin, context: context)
            do {
                try context.save()
            } catch {
                configureError(.failedToSaveEntity(error: error as NSError))
            }
        }
    }

    func delete(_ priceAlert: PriceAlert) {
        context.delete(priceAlert)
        do {
            try context.save()
        } catch {
            configureError(.failedToDeleteEntity(error: error as NSError))
        }
    }

    func configureError(_ error: PersistenceError) {
        self.errorMessage = error.errorDescription
        showErrorAlert = true
    }
}
