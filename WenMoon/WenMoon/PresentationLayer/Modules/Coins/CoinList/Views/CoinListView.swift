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
    
    @State private var selectedCoin: CoinData?
    @State private var swipedCoin: CoinData?
    
    @State private var viewDidAppear = false
    @State private var showCoinSelectionView = false
    @State private var showAuthAlert = false
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            NavigationStack {
                VStack {
                    let coins = viewModel.coins
                    if coins.isEmpty {
                        Spacer()
                        PlaceholderView(text: "No coins added yet")
                        Spacer()
                    } else {
                        List {
                            let pinnedCoins = viewModel.pinnedCoins
                            let unpinnedCoins = viewModel.unpinnedCoins
                            
                            if !pinnedCoins.isEmpty {
                                Section(header: Text("Pinned")) {
                                    ForEach(pinnedCoins, id: \.self) { coin in
                                        makeCoinView(coin)
                                            .transition(.move(edge: .bottom))
                                    }
                                    .onDelete(perform: deletePinnedCoin)
                                    .onMove(perform: movePinnedCoin)
                                }
                            }
                            
                            if !unpinnedCoins.isEmpty {
                                Section(header: Text("All")) {
                                    ForEach(unpinnedCoins, id: \.self) { coin in
                                        makeCoinView(coin)
                                            .transition(.move(edge: .top))
                                    }
                                    .onDelete(perform: deleteUnpinnedCoin)
                                    .onMove(perform: moveUnpinnedCoin)
                                }
                            }
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
                .navigationTitle("Coins")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showCoinSelectionView = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
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
            guard !viewDidAppear else { return }
            await viewModel.fetchCoins()
            viewDidAppear = true
        }
    }
    
    // MARK: - Subviews
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
                            .clipShape(Circle())
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
                        .foregroundColor(isPriceChangeNegative ? .wmRed : .wmGreen)
                        .animation(.easeInOut, value: imageName)
                    
                    RollingNumberView(
                        value: coin.priceChangePercentage24H,
                        formatter: { $0.formattedAsPercentage() },
                        font: .caption2.bold(),
                        foregroundColor: isPriceChangeNegative ? .wmRed : .wmGreen
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
            
            Button {
                coin.isPinned ? viewModel.unpinCoin(coin) : viewModel.pinCoin(coin)
            } label: {
                Image(systemName: coin.isPinned ? "pin.slash.fill" : "pin.fill")
            }
            .tint(.indigo)
        }
    }
    
    // MARK: - Private Methods
    private func deletePinnedCoin(at offsets: IndexSet) {
        let pinnedCoins = viewModel.pinnedCoins
        for index in offsets {
            Task {
                await viewModel.deleteCoin(pinnedCoins[index].id)
            }
        }
    }
    
    private func deleteUnpinnedCoin(at offsets: IndexSet) {
        let unpinnedCoins = viewModel.unpinnedCoins
        for index in offsets {
            Task {
                await viewModel.deleteCoin(unpinnedCoins[index].id)
            }
        }
    }
    
    private func movePinnedCoin(from source: IndexSet, to destination: Int) {
        viewModel.moveCoin(from: source, to: destination, isPinned: true)
    }
    
    private func moveUnpinnedCoin(from source: IndexSet, to destination: Int) {
        viewModel.moveCoin(from: source, to: destination, isPinned: false)
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
