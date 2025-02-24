//
//  ContentView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var coinSelectionViewModel = CoinSelectionViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    
    @State private var scrollMarqueeText = false
    @State private var viewDidLoad = false
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(contentViewModel.globalMarketDataItems, id: \.self) { item in
                    makeGlobalMarketItemView(item)
                }
            }
            .frame(width: 800, height: 20)
            .offset(x: scrollMarqueeText ? -600 : 600)
            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: scrollMarqueeText)
            
            TabView(selection: $contentViewModel.startScreenIndex) {
                CoinListView()
                    .tabItem { Image("coins") }
                    .tag(0)
                PortfolioView()
                    .tabItem { Image("bag") }
                    .tag(1)
                CryptoCompareView()
                    .tabItem { Image("arrows.swap") }
                    .tag(2)
                EducationView()
                    .tabItem { Image("books") }
                    .tag(3)
                AccountView()
                    .tabItem { Image("person") }
                    .tag(4)
            }
        }
        .tint(.neonBlue)
        .environmentObject(coinSelectionViewModel)
        .environmentObject(accountViewModel)
        .onAppear {
            guard !viewDidLoad else { return }
            
            contentViewModel.fetchStartScreen()
            accountViewModel.signOutUserIfNeeded()
            
            Task {
                await accountViewModel.fetchAccount()
                await fetchGlobalMarketDataItems()
            }
            
            viewDidLoad = true
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeGlobalMarketItemView(_ item: GlobalMarketDataItem) -> some View {
        HStack(spacing: 4) {
            Text(item.type.title)
                .font(.footnote)
                .foregroundColor(.softGray)
            Text(item.value)
                .font(.footnote).bold()
        }
    }
    
    // MARK: - Helpers
    private func fetchGlobalMarketDataItems() async {
        await contentViewModel.fetchAllGlobalMarketData()
        await MainActor.run {
            scrollMarqueeText = contentViewModel.isAllMarketDataItemsFetched
        }
    }
}
