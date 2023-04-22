//
//  PriceAlertListView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI
import CoreData

struct PriceAlertListView: View {

    @State private var coins: [Coin] = []

    var body: some View {
        NavigationView {
            List(coins) { coin in
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: coin.image)) { image in
                        image
                            .resizable()
                            .frame(width: 20, height: 20)
                    } placeholder: {
                        ProgressView()
                    }

                    Text("\(coin.name) (\(coin.symbol.uppercased()))")
                }
                .swipeActions {
                    Button(role: .destructive) {
                        if let index = coins.firstIndex(where: { $0.id == coin.id }) {
                            coins.remove(at: index)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .navigationTitle("Price Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddPriceAlertView { selectedCoin in
                            coins.append(selectedCoin)
                        }
                        .navigationBarTitle("Add Price Alert")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
