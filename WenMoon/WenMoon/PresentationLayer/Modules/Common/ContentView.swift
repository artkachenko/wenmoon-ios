//
//  ContentView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Body
    var body: some View {
        TabView {
            CoinListView()
                .tabItem {
                    Image("CoinsIcon")
                }
            
            PortfolioView()
                .tabItem {
                    Image("PortfolioIcon")
                }
            
            CryptoCompareView()
                .tabItem {
                    Image("SwapIcon")
                }
            
            EducationView()
                .tabItem {
                    Image("BooksIcon")
                }
            
            AccountView()
                .tabItem {
                    Image("PersonIcon")
                }
        }
    }
}
