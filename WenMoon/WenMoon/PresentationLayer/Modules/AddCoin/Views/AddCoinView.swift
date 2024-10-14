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
                    ZStack(alignment: .leading) {
                        if let rank = coin.marketCapRank {
                            Text(String(rank))
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("N/A")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 12) {
                            AsyncImage(url: coin.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(12)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 24, height: 24)

                            Text(coin.name).font(.headline)

                            Spacer()
                        }
                        .padding(.leading, 36)
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
            .navigationTitle("Add Coin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: searchText) { _, query in
                viewModel.searchCoins(by: query)
            }
            .onChange(of: viewModel.errorMessage) { _, errorMessage in
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
