//
//  ContentView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var scrollText = false
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(viewModel.globalMarketItems, id: \.self) { item in
                    makeGlobalMarketItemView(item)
                }
            }
            .frame(width: 940, height: 20)
            .offset(x: scrollText ? -680 : 680)
            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: scrollText)
            
            TabView {
                CoinListView()
                    .tabItem {
                        Image("coins")
                    }
                
                PortfolioView()
                    .tabItem {
                        Image("bag")
                    }
                
                CryptoCompareView()
                    .tabItem {
                        Image("arrows.swap")
                    }
                
                EducationView()
                    .tabItem {
                        Image("books")
                    }
                
                AccountView()
                    .tabItem {
                        Image("person")
                    }
            }
        }
        .task {
            await viewModel.fetchGlobalCryptoMarketData()
            await viewModel.fetchGlobalMarketData()
        }
        .onAppear {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(1))
                scrollText = true
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeGlobalMarketItemView(_ item: GlobalMarketItem) -> some View {
        HStack(spacing: 4) {
            Text(item.type.title)
                .font(.footnote)
                .foregroundColor(.lightGray)
            
            Text(item.value)
                .font(.footnote)
                .bold()
        }
    }
}
