//
//  PriceAlertListView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI
import CoreData

struct PriceAlertListView: View {

    @StateObject private var priceAlertListViewModel = PriceAlertListViewModel()
    @StateObject private var addPriceAlertViewModel = AddPriceAlertViewModel()

    @State private var showAddPriceAlertView = false
    @State private var showErrorAlert = false
    @State private var showSetPriceAlertConfirmation = false

    @State private var capturedPriceAlert: PriceAlertEntity?
    @State private var targetPrice: Double?

    var body: some View {
        NavigationView {
            List(priceAlertListViewModel.priceAlerts, id: \.self) { priceAlert in
                HStack(spacing: .zero) {
                    if let uiImage = UIImage(data: priceAlert.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(priceAlert.name)
                            .font(.headline)

                        // TODO: - Move the formatting of values to the PriceAlertListViewModel
                        HStack(spacing: 4) {
                            Text("\(priceAlert.currentPrice.formatValue()) $")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text("\(priceAlert.priceChange.formatValue(shouldShowPrefix: true))%")
                                .foregroundColor(priceAlert.priceChange.isNegative ? .red : .green)
                                .font(.caption2)
                        }
                    }
                    .padding(.leading, 16)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Toggle("", isOn: Binding<Bool>(
                            get: { priceAlert.isActive },
                            set: { isActive in
                                if isActive {
                                    capturedPriceAlert = priceAlert
                                    showSetPriceAlertConfirmation = true
                                } else {
                                    priceAlertListViewModel.setPriceAlert(priceAlert, targetPrice: nil)
                                }
                            }
                        ))

                        if let targetPrice = priceAlert.targetPrice?.doubleValue {
                            Text("\(targetPrice.formatValue()) $")
                                .font(.caption)
                        } else {
                            Text("Not set")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        priceAlertListViewModel.delete(priceAlert)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .navigationTitle("Price Alerts")
            .refreshable {
                priceAlertListViewModel.fetchPriceAlerts()
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
            .onChange(of: priceAlertListViewModel.errorMessage) { errorMessage in
                showErrorAlert = errorMessage != nil
            }
            .alert(priceAlertListViewModel.errorMessage ?? "", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Set Price Alert", isPresented: $showSetPriceAlertConfirmation, actions: {
                TextField("Target Price", value: $targetPrice, format: .number)
                    .keyboardType(.decimalPad)

                Button("Confirm") {
                    if let priceAlert = capturedPriceAlert {
                        priceAlertListViewModel.setPriceAlert(priceAlert, targetPrice: targetPrice)
                        capturedPriceAlert = nil
                        targetPrice = nil
                    }
                }

                Button("Cancel", role: .cancel) {
                    capturedPriceAlert = nil
                    targetPrice = nil
                }
            }) {
                Text("Please enter your target price in USD, and our system will notify you when it is reached.")
            }
            .sheet(isPresented: $showAddPriceAlertView) {
                AddPriceAlertView(didSelectCoin: didSelectCoin)
                    .environmentObject(addPriceAlertViewModel)
            }
            .onAppear {
                priceAlertListViewModel.fetchPriceAlerts()
            }
        }
    }

    private func didSelectCoin(coin: Coin, marketData: CoinMarketData?, targetPrice: Double?) {
        guard let marketData else {
            priceAlertListViewModel.createNewPriceAlert(from: coin, targetPrice: targetPrice)
            return
        }
        priceAlertListViewModel.createNewPriceAlert(from: coin,
                                                    marketData: marketData,
                                                    targetPrice: targetPrice)
    }
}
