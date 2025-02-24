//
//  CoinListView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI

struct CoinListView: View {
    // MARK: - Properties
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @StateObject private var coinListViewModel = CoinListViewModel()
    
    @State private var selectedCoin: CoinData?
    @State private var swipedCoin: CoinData?
    
    @State private var showCoinSelectionView = false
    @State private var showAuthAlert = false
    @State private var viewDidLoad = false
    
    private var coins: [CoinData] { coinListViewModel.coins }
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $coinListViewModel.errorMessage) {
            NavigationStack {
                VStack {
                    if coins.isEmpty {
                        Spacer()
                        PlaceholderView(text: "No coins added yet")
                        Spacer()
                    } else {
                        List {
                            let pinnedCoins = coinListViewModel.pinnedCoins
                            let unpinnedCoins = coinListViewModel.unpinnedCoins
                            
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
                                await fetchCoinsAndPriceAlerts()
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: coins)
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
        .sheet(isPresented: $showCoinSelectionView) {
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
                coinListViewModel.toggleOffPriceAlert(for: priceAlertID)
            }
        }
        .task {
            guard !viewDidLoad else { return }
            
            await fetchCoinsAndPriceAlerts()
            coinListViewModel.triggerImpactFeedback()
            
            viewDidLoad = true
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
                        Image("bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.softGray)
                            .padding(4)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .padding(.trailing, -8)
                            .padding(.top, -8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.symbol)
                        .font(.headline)
                    
                    Text(coin.marketCap.formattedWithAbbreviation(suffix: "$"))
                        .font(.caption2).bold()
                        .foregroundColor(.gray)
                }
                .padding(.leading, 16)
                
                Spacer()
                
                let isPriceChangeNegative = coin.priceChangePercentage24H?.isNegative ?? false
                HStack(spacing: 8) {
                    Image(isPriceChangeNegative ? "arrow.decrease" : "arrow.increase")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    
                    Text(coin.priceChangePercentage24H.formattedAsPercentage())
                        .font(.caption2).bold()
                }
                .foregroundColor(isPriceChangeNegative ? .neonPink : .neonGreen)
            }
            
            Text(coin.currentPrice.formattedAsCurrency())
                .font(.footnote).bold()
                .padding(.trailing, 100)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedCoin = coin
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    try await Task.sleep(for: .milliseconds(200))
                    await coinListViewModel.deleteCoin(coin.id)
                }
            } label: {
                Image("trash")
            }
            .tint(.neonPink)
            
            Button {
                coin.isPinned ? coinListViewModel.unpinCoin(coin) : coinListViewModel.pinCoin(coin)
            } label: {
                Image(systemName: coin.isPinned ? "pin.slash.fill" : "pin.fill")
            }
            .tint(.neonCyan)
        }
        .swipeActions(edge: .leading) {
            Button {
                guard (accountViewModel.account != nil) else {
                    showAuthAlert = true
                    return
                }
                swipedCoin = coin
            } label: {
                Image("bell.add.fill")
            }
            .tint(.neonYellow)
        }
    }
    
    // MARK: - Private Methods
    private func fetchCoinsAndPriceAlerts() async {
        await coinListViewModel.fetchCoins()
        await coinListViewModel.fetchPriceAlerts(for: accountViewModel.account)
    }
    
    private func deletePinnedCoin(at offsets: IndexSet) {
        let pinnedCoins = coinListViewModel.pinnedCoins
        for index in offsets {
            Task {
                await coinListViewModel.deleteCoin(pinnedCoins[index].id)
            }
        }
    }
    
    private func deleteUnpinnedCoin(at offsets: IndexSet) {
        let unpinnedCoins = coinListViewModel.unpinnedCoins
        for index in offsets {
            Task {
                await coinListViewModel.deleteCoin(unpinnedCoins[index].id)
            }
        }
    }
    
    private func movePinnedCoin(from source: IndexSet, to destination: Int) {
        coinListViewModel.moveCoin(from: source, to: destination, isPinned: true)
    }
    
    private func moveUnpinnedCoin(from source: IndexSet, to destination: Int) {
        coinListViewModel.moveCoin(from: source, to: destination, isPinned: false)
    }
    
    private func handleCoinSelection(coin: Coin, shouldAdd: Bool) {
        Task {
            if shouldAdd {
                await coinListViewModel.saveCoin(coin)
            } else {
                await coinListViewModel.deleteCoin(coin.id)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CoinListView()
}
