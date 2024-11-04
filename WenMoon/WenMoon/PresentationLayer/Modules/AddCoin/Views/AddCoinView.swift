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
    @StateObject private var viewModel = AddCoinViewModel()
    
    @State private var searchText = ""
    @State private var showErrorAlert = false
    
    private(set) var didToggleCoin: ((Coin, Bool) -> Void)?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.coins, id: \.self) { coin in
                        makeCoinView(coin)
                            .onAppear {
                                Task {
                                    await viewModel.fetchCoinsOnNextPageIfNeeded(coin)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Add Coins")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: "e.g. Bitcoin")
                .scrollDismissesKeyboard(.immediately)
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
                        message: Text(viewModel.errorMessage!),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onChange(of: viewModel.errorMessage) { _, errorMessage in
                    showErrorAlert = errorMessage != nil
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeCoinView(_ coin: Coin) -> some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: .zero) {
                if let url = coin.image {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .grayscale(0.4)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 36, height: 36)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 36, height: 36)
                        
                        Text(coin.name.prefix(1))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .brightness(-0.1)
                }
                
                Text(coin.name)
                    .font(.headline)
                    .frame(maxWidth: 240, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.leading, 12)
                
                Spacer()
            }
            
            Toggle("", isOn: Binding<Bool>(
                get: { viewModel.isCoinSaved(coin) },
                set: { isSaved in
                    didToggleCoin?(coin, isSaved)
                    viewModel.toggleSaveState(for: coin)
                }
            ))
            .tint(.wmPink)
            .scaleEffect(0.85)
            .padding(.trailing, -28)
        }
        .padding([.top, .bottom], 4)
    }
}

// MARK: - Previews
struct AddCoinView_Previews: PreviewProvider {
    static var previews: some View {
        AddCoinView(
            didToggleCoin: { coin, isSaved in
                print("Toggled \(coin.name): \(isSaved)")
            }
        )
    }
}
