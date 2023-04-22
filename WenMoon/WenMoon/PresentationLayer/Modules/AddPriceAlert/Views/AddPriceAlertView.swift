//
//  AddPriceAlertView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import SwiftUI

struct AddPriceAlertView: View {

    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode

    @StateObject private var viewModel = AddPriceAlertViewModel()

    @State private var searchText = ""

    private(set) var didSelectCoin: ((Coin) -> Void)?

    // MARK: - Body

    var body: some View {
        ZStack {
            List(viewModel.coins) { coin in
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: coin.image)) { image in
                        image
                            .resizable()
                            .frame(width: 20, height: 20)
                    } placeholder: {
                        ProgressView()
                    }

                    Text("\(coin.name) (\(coin.symbol.uppercased()))")

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    didSelectCoin?(coin)
                    presentationMode.wrappedValue.dismiss()
                }
                .onAppear {
                    if searchText.isEmpty && coin.id == viewModel.coins.last?.id {
                        viewModel.fetchCoinsOnNextPage()
                    }
                }
            }
            .refreshable {
                if searchText.isEmpty {
                    viewModel.fetchCoins()
                }
            }
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "e.g. Bitcoin")

            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        .onChange(of: searchText) { query in
            viewModel.searchCoins(by: query)
        }
        .onAppear {
            viewModel.fetchCoins()
        }
    }
}
