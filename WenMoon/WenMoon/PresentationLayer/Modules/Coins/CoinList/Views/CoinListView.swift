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
    
    @State private var selectedCoin: CoinData!
    @State private var swipedCoin: CoinData!
    
    @State private var chartDrawProgress: CGFloat = .zero
    
    @State private var showCoinSelectionView = false
    @State private var showAuthAlert = false
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            NavigationView {
                let coins = viewModel.coins
                VStack {
                    if coins.isEmpty {
                        makeAddCoinsButton()
                        Spacer()
                        PlaceholderView(text: "No coins added yet")
                        Spacer()
                    } else {
                        List {
                            ForEach(coins, id: \.self) { coin in
                                makeCoinView(coin)
                            }
                            .onDelete(perform: deleteCoin)
                            .onMove(perform: moveCoin)
                            
                            makeAddCoinsButton()
                        }
                        .listStyle(.plain)
                        .refreshable {
                            Task {
                                await viewModel.fetchMarketData()
                                await viewModel.fetchPriceAlerts()
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: coins)
                .navigationTitle("Coins")
            }
        }
        .sheet(isPresented: $showCoinSelectionView, onDismiss: {
            Task {
                await viewModel.fetchMarketData()
            }
        }) {
            CoinSelectionView(didToggleCoin: handleCoinSelection)
        }
        .sheet(item: $selectedCoin, onDismiss: {
            selectedCoin = nil
        }) { coin in
            CoinDetailsView(coin: coin)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(36)
        }
        .sheet(item: $swipedCoin, onDismiss: {
            swipedCoin = nil
        }) { coin in
            PriceAlertsView(coin: coin)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(36)
        }
        .alert(isPresented: $showAuthAlert) {
            Alert(
                title: Text("Need to Sign In, Buddy!"),
                message: Text("You gotta slide over to the Account tab and log in to check out your price alerts."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .targetPriceReached)) { notification in
            if let priceAlertID = notification.userInfo?["priceAlertID"] as? String {
                viewModel.toggleOffPriceAlert(for: priceAlertID)
            }
        }
        .task {
            await viewModel.fetchCoins()
            await viewModel.fetchPriceAlerts()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeAddCoinsButton() -> some View {
        Button(action: {
            showCoinSelectionView = true
        }) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("Add Coins")
            }
            .frame(maxWidth: .infinity)
        }
        .listRowSeparator(.hidden)
        .buttonStyle(.borderless)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func makeCoinView(_ coin: CoinData) -> some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: .zero) {
                ZStack(alignment: .topTrailing) {
                    CoinImageView(
                        imageData: coin.imageData,
                        placeholderText: coin.symbol,
                        size: 48
                    )
                    
                    if !coin.priceAlerts.isEmpty {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.lightGray)
                            .padding(4)
                            .background(Color(.systemBackground))
                            .clipShape(.circle)
                            .padding(.trailing, -8)
                            .padding(.top, -8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.symbol.uppercased())
                        .font(.headline)
                    
                    RollingNumberView(
                        value: coin.marketCap,
                        formatter: { $0.formattedWithAbbreviation(suffix: "$") },
                        font: .caption2.bold(),
                        foregroundColor: .gray
                    )
                }
                .padding(.leading, 16)
                
                Spacer()
                
                HStack(spacing: 8) {
                    let isPriceChangeNegative = coin.priceChangePercentage24H?.isNegative ?? false
                    let imageName = isPriceChangeNegative ? "arrow.decrease" : "arrow.increase"
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.wmPink)
                        .animation(.easeInOut, value: imageName)
                    
                    RollingNumberView(
                        value: coin.priceChangePercentage24H,
                        formatter: { $0.formattedAsPercentage() },
                        font: .caption2.bold(),
                        foregroundColor: .wmPink
                    )
                }
            }
            
            RollingNumberView(
                value: coin.currentPrice,
                formatter: { $0.formattedAsCurrency() },
                font: .footnote.bold(),
                foregroundColor: .white
            )
            .padding(.trailing, 100)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCoin = coin
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
            
            Button {
                guard viewModel.userID != nil else {
                    showAuthAlert = true
                    return
                }
                swipedCoin = coin
            } label: {
                Image(systemName: "bell.fill")
            }
            .tint(.blue)
        }
    }
    
    // MARK: - Helper Methods
    private func deleteCoin(at offsets: IndexSet) {
        for index in offsets {
            let coinID = viewModel.coins[index].id
            Task {
                await viewModel.deleteCoin(coinID)
            }
        }
    }
    
    private func moveCoin(from source: IndexSet, to destination: Int) {
        viewModel.coins.move(fromOffsets: source, toOffset: destination)
        viewModel.saveCoinsOrder()
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

// MARK: - Preview
#Preview {
    CoinListView()
}
