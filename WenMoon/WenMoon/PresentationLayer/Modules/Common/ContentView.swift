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
}
