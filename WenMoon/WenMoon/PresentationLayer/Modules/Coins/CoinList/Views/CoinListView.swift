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
    @State private var isEditMode: EditMode = .inactive
    @State private var chartDrawProgress: CGFloat = .zero
    
    @State private var showAddCoinView = false
    @State private var showAuthAlert = false
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            NavigationView {
                List {
                    ForEach(viewModel.coins, id: \.self) { coin in
                        makeCoinView(coin)
                    }
                    .onMove(perform: moveCoin)
                    
                    Button(action: {
                        showAddCoinView.toggle()
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
                .environment(\.editMode, $isEditMode)
                .animation(.default, value: viewModel.coins)
                .refreshable {
                    Task {
                        await viewModel.fetchMarketData()
                        await viewModel.fetchPriceAlerts()
                    }
                }
                .navigationTitle("Coins")
            }
        }
        .fullScreenCover(isPresented: $showAddCoinView) {
            AddCoinView(didToggleCoin: handleCoinSelection)
        }
        .fullScreenCover(item: $selectedCoin, onDismiss: {
            selectedCoin = nil
        }) { coin in
            CoinDetailsView(coin: coin, chartData: viewModel.chartData[coin.symbol] ?? [:])
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
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeCoinView(_ coin: CoinData) -> some View {
        HStack(spacing: .zero) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                    
                    if let data = coin.imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .clipShape(.circle)
                    } else {
                        Text(coin.name.prefix(1))
                            .font(.body)
                            .foregroundColor(.wmBlack)
                    }
                }
                .brightness(-0.1)
                
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
        .onLongPressGesture {
            isEditMode = .active
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
                    showAuthAlert.toggle()
                    return
                }
                swipedCoin = coin
            } label: {
                Image(systemName: "bell.fill")
            }
            .tint(.blue)
        }
    }
    
    private func moveCoin(from source: IndexSet, to destination: Int) {
        viewModel.coins.move(fromOffsets: source, toOffset: destination)
        viewModel.saveCoinOrder()
    }
    
    private func handleCoinSelection(coin: Coin, shouldAdd: Bool) {
        Task {
            if shouldAdd {
                await viewModel.saveCoin(coin)
                await viewModel.fetchChartData(for: coin.symbol)
            } else {
                await viewModel.deleteCoin(coin.id)
            }
            viewModel.saveCoinOrder()
        }
    }
}

// MARK: - Preview
#Preview {
    CoinListView()
}
