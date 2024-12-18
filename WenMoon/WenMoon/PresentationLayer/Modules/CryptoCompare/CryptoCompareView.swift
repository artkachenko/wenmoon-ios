//
//  CryptoCompareView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import SwiftUI

struct CryptoCompareView: View {
    // MARK: - Properties
    @StateObject private var viewModel = CryptoCompareViewModel()
    @State private var selectedPriceOption: PriceOption = .now
    @State private var coinToBeCompared: Coin?
    @State private var coinToCompareWith: Coin?
    @State private var cachedImage1: Image?
    @State private var cachedImage2: Image?
    @State private var isSelectingFirstCoin = true
    @State private var showCoinSelectionView = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                makeCoinSelectionView(
                    coin: $coinToBeCompared,
                    cachedImage: $cachedImage1,
                    placeholder: "Select Coin A",
                    isFirstCoin: true
                )
                
                Button(action: {
                    swap(&coinToBeCompared, &coinToCompareWith)
                    swap(&cachedImage1, &cachedImage2)
                }) {
                    Image("SwapIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(90))
                }
                .disabled(coinToBeCompared == nil || coinToCompareWith == nil)
                
                makeCoinSelectionView(
                    coin: $coinToCompareWith,
                    cachedImage: $cachedImage2,
                    placeholder: "Select Coin B",
                    isFirstCoin: false
                )
                
                if let coinToBeCompared, let coinToCompareWith {
                    VStack(spacing: 16) {
                        Picker("Price Option", selection: $selectedPriceOption) {
                            ForEach(PriceOption.allCases, id: \.self) { option in
                                Text("\(coinToCompareWith.symbol.uppercased()) \(option.rawValue)").tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: .zero) {
                                Text(coinToBeCompared.symbol.uppercased())
                                    .foregroundColor(.white)
                                    .bold()
                                
                                Text(" WITH THE MARKET CAP OF ")
                                
                                Text(coinToCompareWith.symbol.uppercased())
                                    .foregroundColor(.white)
                                    .bold()
                                
                                Text(" \(selectedPriceOption.rawValue)")
                                    
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                            
                            if let price = viewModel.calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: selectedPriceOption),
                               let multiplier = viewModel.calculateMultiplier(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: selectedPriceOption) {
                                HStack {
                                    Text(price.formattedAsCurrency())
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text(multiplier.formattedAsMultiplier())
                                        .foregroundColor(viewModel.isPositiveMultiplier(multiplier) ? .green : .red)
                                        .opacity(0.8)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showCoinSelectionView) {
                CoinSelectionView(mode: .selection, didSelectCoin: { selectedCoin in
                    loadAndCacheCoinImage(for: selectedCoin)
                    
                    if isSelectingFirstCoin {
                        coinToBeCompared = selectedCoin
                    } else {
                        coinToCompareWith = selectedCoin
                    }
                })
            }
            .navigationTitle("Compare")
        }
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeCoinSelectionView(
        coin: Binding<Coin?>,
        cachedImage: Binding<Image?>,
        placeholder: String,
        isFirstCoin: Bool
    ) -> some View {
        HStack {
            Button(action: {
                isSelectingFirstCoin = isFirstCoin
                showCoinSelectionView = true
            }) {
                if let coin = coin.wrappedValue {
                    makeCoinView(coin, cachedImage.wrappedValue)
                } else {
                    makeCoinPlaceholderView(placeholder)
                }
            }
            
            if coin.wrappedValue != nil {
                Button(action: {
                    coin.wrappedValue = nil
                    cachedImage.wrappedValue = nil
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 8)
            }
        }
    }
    
    @ViewBuilder
    private func makeCoinView(_ coin: Coin, _ cachedImage: Image?) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                
                if let cachedImage {
                    cachedImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(.circle)
                } else {
                    Text(coin.name.prefix(1))
                        .font(.callout)
                        .foregroundColor(.wmBlack)
                }
            }
            .brightness(-0.1)
            
            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(coin.currentPrice.formattedAsCurrency())
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func makeCoinPlaceholderView(_ text: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 36, height: 36)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    private func loadAndCacheCoinImage(for coin: Coin) {
        if let url = coin.image {
            Task {
                if let data = await viewModel.loadImage(from: url),
                   let uiImage = UIImage(data: data) {
                    if isSelectingFirstCoin {
                        cachedImage1 = Image(uiImage: uiImage)
                    } else {
                        cachedImage2 = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}

// MARK: - Previews
struct CryptoCompareView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoCompareView()
    }
}
