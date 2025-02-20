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
    
    @State private var scrollMarqueeText = false
    
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
        .environmentObject(coinSelectionViewModel)
        .task {
            await fetchGlobalMarketDataItems()
        }
        .onAppear {
            contentViewModel.fetchStartScreen()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeGlobalMarketItemView(_ item: GlobalMarketDataItem) -> some View {
        HStack(spacing: 4) {
            Text(item.type.title)
                .font(.footnote)
                .foregroundColor(.lightGray)
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
