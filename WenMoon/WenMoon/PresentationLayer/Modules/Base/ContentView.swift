//
//  ContentView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CoinListView()
                .tabItem {
                    Label("", systemImage: "cylinder.split.1x2.fill")
                }
        }
    }
}
