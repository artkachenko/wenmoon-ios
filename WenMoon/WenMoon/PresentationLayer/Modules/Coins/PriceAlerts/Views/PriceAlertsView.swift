//
//  PriceAlertsView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 28.11.24.
//

import SwiftUI

struct PriceAlertsView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var priceAlertsViewModel = PriceAlertsViewModel()

    @FocusState private var isTextFieldFocused: Bool

    @State private var targetPrice: Double?
    
    private let coin: CoinData

    // MARK: - Initializers
    init(coin: CoinData) {
        self.coin = coin
    }
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $priceAlertsViewModel.errorMessage) {
            VStack(spacing: .zero) {
                let priceAlerts = coin.priceAlerts
                
                ZStack {
                    Text("Price Alerts")
                        .font(.headline)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.white, Color(.systemGray5))
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                
                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        if let targetPrice {
                            let targetDirection = priceAlertsViewModel.getTargetDirection(for: targetPrice, price: coin.currentPrice)
                            Image(targetDirection.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(targetDirection.color)
                        }
                        
                        TextField("Enter Target Price", value: $targetPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($isTextFieldFocused)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(UnderlinedTextFieldStyle())
                            .font(.headline)
                        
                        Text("$")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 32)
                    
                    ZStack {
                        if priceAlertsViewModel.isCreatingPriceAlert {
                            ProgressView()
                        } else {
                            let isCreateButtonDisabled = priceAlertsViewModel.shouldDisableCreateButton(priceAlerts: coin.priceAlerts, targetPrice: targetPrice)
                            Button(action: {
                                if let targetPrice {
                                    Task {
                                        await priceAlertsViewModel.createPriceAlert(for: coin, targetPrice: targetPrice)
                                    }
                                }
                            }) {
                                Text("Create")
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(isCreateButtonDisabled ? .gray.opacity(0.3) : .white)
                                    .foregroundColor(isCreateButtonDisabled ? .gray : .black)
                                    .cornerRadius(32)
                            }
                            .disabled(isCreateButtonDisabled)
                        }
                    }
                    .frame(height: 32)
                }
                .padding(.horizontal, 48)
                .padding(.bottom, priceAlerts.isEmpty ? .zero : 16)
                
                Spacer()
                
                VStack {
                    if priceAlerts.isEmpty {
                        Spacer()
                        PlaceholderView(text: "No price alerts yet")
                        Spacer()
                    } else {
                        List {
                            ForEach(priceAlerts, id: \.self) { priceAlert in
                                makePriceAlertCell(priceAlert)
                            }
                        }
                        .listStyle(.plain)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                }
                .animation(.easeInOut, value: priceAlerts)
            }
            .background(Color.obsidian)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isTextFieldFocused = false
            }
        )
        .onAppear {
            targetPrice = coin.currentPrice
        }
    }
    
    @ViewBuilder
    private func makePriceAlertCell(_ priceAlert: PriceAlert) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(priceAlert.symbol)
                    .font(.body)
                
                HStack(spacing: 8) {
                    let targetDirection = priceAlertsViewModel.getTargetDirection(for: priceAlert.targetPrice, price: coin.currentPrice)
                    Image(targetDirection.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(targetDirection.color)
                    
                    Text(priceAlert.targetPrice.formattedAsCurrency())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if priceAlertsViewModel.deletingPriceAlertIDs.contains(priceAlert.id) {
                ProgressView()
            } else {
                Button(action: {
                    Task {
                        await priceAlertsViewModel.deletePriceAlert(priceAlert, for: coin)
                    }
                }) {
                    Image("trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .listRowBackground(Color.obsidian)
    }
}
