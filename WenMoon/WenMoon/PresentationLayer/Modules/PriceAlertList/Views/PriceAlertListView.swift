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

    @State private var showAddPriceAlertView = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            List(viewModel.priceAlerts, id: \.self) { priceAlert in
                HStack(spacing: 16) {
                    if let uiImage = UIImage(data: priceAlert.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(priceAlert.name).font(.headline)

                        HStack(spacing: 4) {
                            Text("\(priceAlert.currentPrice.formatValue()) $")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text("\(priceAlert.priceChange.formatValue(shouldShowPrefix: true))%")
                                .foregroundColor(priceAlert.priceChange.isNegative ? .red : .green)
                                .font(.caption2)
                        }
                    }

                    Spacer()
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
            .refreshable {
                viewModel.fetchPriceAlerts()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPriceAlertView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) { errorMessage in
                showErrorAlert = errorMessage != nil
            }
            .alert(viewModel.errorMessage ?? "", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showAddPriceAlertView) {
                AddPriceAlertView { selectedCoin in
                    viewModel.fetchMarketData(for: [selectedCoin])
                }
            }
            .onAppear {
                viewModel.fetchPriceAlerts()
            }
        }
    }
}
