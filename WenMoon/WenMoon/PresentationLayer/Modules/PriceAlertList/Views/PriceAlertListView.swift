//
//  PriceAlertListView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI
import CoreData

struct PriceAlertListView: View {

    @StateObject private var viewModel = PriceAlertListViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.priceAlerts, id: \.self) { priceAlert in
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: priceAlert.image)) { image in
                        image
                            .resizable()
                            .frame(width: 20, height: 20)
                    } placeholder: {
                        ProgressView()
                    }

                    Text("\(priceAlert.name) (\(priceAlert.symbol.uppercased()))")
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.delete(priceAlert)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .navigationTitle("Price Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddPriceAlertView { selectedCoin in
                            viewModel.savePriceAlert(selectedCoin)
                        }
                        .navigationBarTitle("Add Price Alert")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                viewModel.fetchPriceAlerts()
            }
        }
    }
}
