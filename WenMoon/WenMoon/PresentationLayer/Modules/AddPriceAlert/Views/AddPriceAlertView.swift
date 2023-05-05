//
//  AddPriceAlertView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI

struct AddPriceAlertView: View {

    // MARK: - Properties

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var viewModel: AddPriceAlertViewModel

    @State private var searchText = ""
    @State private var showErrorAlert = false
    @State private var showSetPriceAlertConfirmation = false

    @State private var capturedCoin: Coin?
    @State private var targetPrice: Double?

    private(set) var didSelectCoin: ((Coin, CoinMarketData?, _ targetPrice: Double?) -> Void)?

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.coins, id: \.self) { coin in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: coin.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 24, height: 24)

                        Text(coin.name).font(.headline)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        capturedCoin = coin
                        showSetPriceAlertConfirmation = true
                    }
                    .onAppear {
                        if searchText.isEmpty && coin.id == viewModel.coins.last?.id {
                            viewModel.fetchCoinsOnNextPage()
                        }
                    }
                }
                .searchable(text: $searchText,
                            placement: .toolbar,
                            prompt: "e.g. Bitcoin")
                .scrollDismissesKeyboard(.immediately)

                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Add Price Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: searchText) { query in
                viewModel.searchCoins(by: query)
            }
            .onChange(of: viewModel.errorMessage) { errorMessage in
                showErrorAlert = errorMessage != nil
            }
            .alert(viewModel.errorMessage ?? "", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Set Price Alert", isPresented: $showSetPriceAlertConfirmation, actions: {
                TextField("Target Price", value: $targetPrice, format: .number)
                    .keyboardType(.decimalPad)

                Button("Confirm") {
                    didSelectCoin(targetPrice)
                }

                Button("Not Now", role: .cancel) {
                    didSelectCoin()
                }
            }) {
                Text("Please enter your target price in USD, and our system will notify you when it is reached.")
            }
            .onAppear {
                viewModel.fetchCoins()
            }
        }
    }

    private func didSelectCoin(_ targetPrice: Double? = nil) {
        guard let coin = capturedCoin else { return }
        let marketData = viewModel.marketData[coin.id]
        didSelectCoin?(coin, marketData, targetPrice)
        capturedCoin = nil
        self.targetPrice = nil
        presentationMode.wrappedValue.dismiss()
    }
}
