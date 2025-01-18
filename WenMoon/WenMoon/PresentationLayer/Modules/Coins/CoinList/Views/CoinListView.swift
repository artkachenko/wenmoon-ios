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
                        .animation(.default, value: viewModel.coins)
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
                .toolbar {
                    if !coins.isEmpty {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            makeSortByButton()
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCoinSelectionView) {
            CoinSelectionView(didToggleCoin: handleCoinSelection)
        }
        .fullScreenCover(item: $selectedCoin, onDismiss: {
            selectedCoin = nil
        }) { coin in
            CoinDetailsView(coin: coin)
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
        .onAppear {
            viewModel.getSavedSortOption()
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
                
                Text(coin.currentPrice.formattedAsCurrency())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                ChartShape(value: coin.priceChangePercentage24H ?? .zero)
                    .trim(from: .zero, to: chartDrawProgress)
                    .stroke(Color.wmPink, lineWidth: 2)
                    .frame(width: 50, height: 10)
                    .onAppear {
                        withAnimation {
                            chartDrawProgress = 1
                        }
                    }
                
                Text(coin.priceChangePercentage24H.formattedAsPercentage())
                    .font(.caption2)
            }
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
    
    @ViewBuilder
    private func makeSortByButton() -> some View {
        Menu("Sort By") {
            ForEach(SortOption.allCases, id: \.self) { sortOption in
                Button {
                    if viewModel.selectedSortOption != sortOption {
                        viewModel.sortCoins(by: sortOption)
                    }
                } label: {
                    HStack {
                        Text(sortOption.title)
                        if viewModel.selectedSortOption == sortOption {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue, .primary)
                        }
                    }
                }
            }
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
        viewModel.saveSortOption(.custom)
        viewModel.saveCoinsOrder(for: .custom)
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
