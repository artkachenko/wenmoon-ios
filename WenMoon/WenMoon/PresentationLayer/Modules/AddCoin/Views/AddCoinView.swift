//
//  AddCoinView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI

struct AddCoinView: View {

    // MARK: - Properties

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var viewModel: AddCoinViewModel

    @State private var searchText = ""
    @State private var showErrorAlert = false

    private(set) var didSelectCoin: ((Coin, MarketData?) -> Void)?

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
                        didSelectCoin?(coin, viewModel.marketData[coin.id])
                        presentationMode.wrappedValue.dismiss()
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
            .onAppear {
                viewModel.fetchCoins()
            }
        }
    }
}
