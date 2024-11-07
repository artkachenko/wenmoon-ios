//
//  CoinDetailsView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 07.11.24.
//

import SwiftUI

struct CoinDetailsView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CoinDetailsViewModel
    
    // MARK: - Initializers
    init(coin: CoinData) {
        _viewModel = StateObject(wrappedValue: CoinDetailsViewModel(coin: coin))
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            let coin = viewModel.coin
            HStack {
                if let imageData = coin.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .cornerRadius(8)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 36, height: 36)
                        
                        Text(coin.name.prefix(1))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .brightness(-0.1)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(coin.symbol.uppercased())
                            .font(.headline)
                            .bold()
                        
                        Text("#\(coin.marketCapRank.formattedOrNone())")
                            .font(.caption)
                            .bold()
                    }
                    
                    Text(coin.currentPrice.formattedAsCurrency())
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    makeDetailRow(label: "Market Cap", value: coin.marketCap.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "24h Volume", value: coin.totalVolume.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "Max Supply", value: coin.maxSupply.formattedWithAbbreviation(placeholder: "∞"))
                    makeDetailRow(label: "All-Time High", value: coin.ath.formattedAsCurrency())
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    makeDetailRow(label: "Fully Diluted Market Cap", value: coin.fullyDilutedValuation.formattedWithAbbreviation(suffix: "$"))
                    makeDetailRow(label: "Circulating Supply", value: coin.circulatingSupply.formattedWithAbbreviation())
                    makeDetailRow(label: "Total Supply", value: coin.totalSupply.formattedWithAbbreviation())
                    makeDetailRow(label: "All-Time Low", value: coin.atl.formattedAsCurrency())
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding([.top, .horizontal], 24)
    }
    
    // MARK: - Private Methods
    @ViewBuilder
    private func makeDetailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.caption)
        }
    }
}

// MARK: - Preview
#Preview {
    CoinDetailsView(coin: CoinData())
}
