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
    @StateObject private var viewModel: PriceAlertsViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var targetPrice: Double?
    
    // MARK: - Initializers
    init(coin: CoinData) {
        _viewModel = StateObject(wrappedValue: PriceAlertsViewModel(coin: coin))
    }
    
    // MARK: - Body
    var body: some View {
        BaseView(errorMessage: $viewModel.errorMessage) {
            VStack(spacing: .zero) {
                let priceAlerts = viewModel.coin.priceAlerts
                
                ZStack {
                    Text("Price Alerts")
                        .font(.headline)
                    
                    HStack {
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
                    .padding(24)
                }
                .padding(.bottom, 16)
                
                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        if let targetPrice {
                            Image(viewModel.getTargetDirection(for: targetPrice).iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.wmPink)
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
                        if viewModel.isCreatingPriceAlert {
                            ProgressView()
                        } else {
                            let isCreateButtonDisabled = viewModel.shouldDisableCreateButton(targetPrice: targetPrice)
                            Button(action: {
                                Task {
                                    await viewModel.createPriceAlert(targetPrice: targetPrice)
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
                
                if priceAlerts.isEmpty {
                    VStack(spacing: 8) {
                        Image("MoonIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                        
                        Text("No price alerts yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                } else {
                    List {
                        ForEach(priceAlerts, id: \.self) { priceAlert in
                            makePriceAlertCell(priceAlert)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            targetPrice = viewModel.coin.currentPrice
        }
    }
    
    @ViewBuilder
    private func makePriceAlertCell(_ priceAlert: PriceAlert) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(priceAlert.symbol.uppercased())
                    .font(.body)
                
                HStack(spacing: 8) {
                    Image(viewModel.getTargetDirection(for: priceAlert.targetPrice).iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.wmPink)
                    
                    Text(priceAlert.targetPrice.formattedAsCurrency())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if viewModel.deletingPriceAlertIDs.contains(priceAlert.id) {
                ProgressView()
            } else {
                Button(action: {
                    Task {
                        await viewModel.deletePriceAlert(priceAlert)
                    }
                }) {
                    Image("TrashIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
