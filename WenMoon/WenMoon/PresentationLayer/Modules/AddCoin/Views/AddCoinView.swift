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
    
    private(set) var didSelectCoin: ((Coin, Bool) -> Void)?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.coins, id: \.self) { coin in
                    makeCoinView(coin)
                        .onAppear {
                            Task {
                                await viewModel.fetchCoinsOnNextPageIfNeeded(coin)
                            }
                        }
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "e.g. Bitcoin")
                .scrollDismissesKeyboard(.immediately)
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Add Coin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: searchText) { _, query in
                Task {
                    await viewModel.handleSearchInput(query)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchCoins()
                    viewModel.fetchSavedCoins()
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: viewModel.errorMessage) { _, errorMessage in
                showErrorAlert = errorMessage != nil
            }
        }
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeCoinView(_ coin: Coin) -> some View {
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
                
                Button(action: {
                    let shouldAdd = !viewModel.isCoinSaved(coin)
                    didSelectCoin?(coin, shouldAdd)
                    viewModel.toggleSaveState(for: coin)
                }) {
                    Image(systemName: viewModel.isCoinSaved(coin) ? "checkmark" : "plus")
                        .foregroundColor(.black)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.leading, 36)
        }
    }
}
