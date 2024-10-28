//
//  CoinListView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI

struct CoinListView: View {
    // MARK: - Properties
    @StateObject private var viewModel = CoinListViewModel()
    
    @State private var shouldShowAddCoinView = false
    @State private var showErrorAlert = false
    @State private var showSetPriceAlertConfirmation = false
    @State private var capturedCoin: CoinData?
    @State private var targetPrice: Double?
    @State private var toggleOffCoinID: String?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.coins, id: \.self) { coin in
                    makeCoinView(coin)
                }
                
                Button(action: {
                    shouldShowAddCoinView.toggle()
                }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Add Coins")
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowSeparator(.hidden)
                .buttonStyle(.borderless)
            }
            .listStyle(.plain)
            .animation(.default, value: viewModel.coins)
            .refreshable {
                Task {
                    await viewModel.fetchCoins()
                }
            }
            .navigationTitle("Coins")
            .onAppear {
                Task {
                    await viewModel.fetchCoins()
                    await viewModel.fetchMarketData()
                    await viewModel.fetchPriceAlerts()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .targetPriceReached)) { notification in
                if let coinID = notification.userInfo?["coinID"] as? String {
                    viewModel.toggleOffPriceAlert(for: coinID)
                }
            }
            .onChange(of: viewModel.errorMessage) { _, errorMessage in
                showErrorAlert = errorMessage != nil
            }
            .sheet(isPresented: $shouldShowAddCoinView) {
                AddCoinView(didToggleCoin: handleCoinSelection)
            }
            .alert(viewModel.errorMessage ?? "", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Set Price Alert", isPresented: $showSetPriceAlertConfirmation, actions: {
                TextField("Target Price", value: $targetPrice, format: .number)
                    .keyboardType(.decimalPad)
                
                Button("Confirm") {
                    if let coin = capturedCoin {
                        Task {
                            await viewModel.setPriceAlert(for: coin, targetPrice: targetPrice)
                            capturedCoin = nil
                            targetPrice = nil
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    capturedCoin = nil
                    targetPrice = nil
                }
            }) {
                Text("Please enter your target price in USD, and our system will notify you when it is reached")
            }
        }
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeCoinView(_ coin: CoinData) -> some View {
        HStack(spacing: .zero) {
            if let data = coin.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .cornerRadius(24)
                    .grayscale(0.5)
            } else {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Text("\(coin.currentPrice.formatValue()) $")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(coin.priceChange.formatValue(shouldShowPrefix: true))%")
                        .font(.caption2)
                }
            }
            .padding(.leading, 16)
            
            Spacer()
        }
        .swipeActions {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteCoin(coin.id)
                }
            } label: {
                Image(systemName: "heart.slash.fill")
            }
            .tint(.wmPink)
        }
    }
    
    private func handleCoinSelection(coin: Coin, shouldAdd: Bool) {
        Task {
            if shouldAdd {
                await viewModel.saveCoin(coin)
            } else {
                await viewModel.deleteCoin(coin.id)
            }
        }
    }
}

// MARK: - Previews
struct CoinListView_Previews: PreviewProvider {
    static var previews: some View {
        CoinListView()
    }
}
