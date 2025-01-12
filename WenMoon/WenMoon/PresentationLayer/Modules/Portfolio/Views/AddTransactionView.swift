//
//  AddTransactionView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 27.12.24.
//

import SwiftUI

struct AddTransactionView: View {
    // MARK: - Nested Types
    enum Mode {
        case add
        case edit
    }
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddTransactionViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var showCoinSelectionView = false
    
    private let mode: Mode
    private let didAddTransaction: ((Transaction) -> Void)?
    private let didEditTransaction: ((Transaction) -> Void)?
    
    // MARK: - Initializers
    init(
        transaction: Transaction? = nil,
        didAddTransaction: ((Transaction) -> Void)? = nil,
        didEditTransaction: ((Transaction) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel(transaction: transaction))
        mode = transaction == nil ? .add : .edit
        self.didAddTransaction = didAddTransaction
        self.didEditTransaction = didEditTransaction
    }
    
    // MARK: - Body
    var body: some View {
        let transaction = viewModel.transaction
        VStack {
            ZStack {
                Text(mode == .add ? "Add Transaction" : "Edit Transaction")
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
            
            makeTransactionFormView(transaction)
            
            let isAddTransactionButtonDisabled = viewModel.shouldDisableAddTransactionsButton()
            Button(action: {
                Task {
                    switch mode {
                    case .add:
                        didAddTransaction?(transaction)
                    case .edit:
                        didEditTransaction?(transaction)
                    }
                    dismiss()
                }
            }) {
                Text(mode == .add ? "Add Transaction" : "Edit Transaction")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(isAddTransactionButtonDisabled ? .gray.opacity(0.3) : .white)
                    .foregroundColor(isAddTransactionButtonDisabled ? .gray : .black)
                    .cornerRadius(32)
            }
            .disabled(isAddTransactionButtonDisabled)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isTextFieldFocused = false
        }
        .sheet(isPresented: $showCoinSelectionView) {
            CoinSelectionView(mode: .selection, didSelectCoin: { selectedCoin in
                Task {
                    let coin = await viewModel.makeCoinData(from: selectedCoin)
                    transaction.coin = coin
                }
            })
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeTransactionFormView(_ transaction: Transaction) -> some View {
        VStack(spacing: 16) {
            Button(action: {
                showCoinSelectionView.toggle()
            }) {
                HStack {
                    if let coin = transaction.coin {
                        HStack(spacing: 12) {
                            CoinImageView(
                                imageData: coin.imageData,
                                placeholderText: coin.symbol,
                                size: 36
                            )
                            
                            Text(coin.symbol.uppercased())
                                .font(.headline)
                        }
                    } else {
                        Text("Select Coin")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }
            }
            .tint(.white)
            .font(.headline)
            
            HStack(spacing: .zero) {
                TextField("Quantity", value: $viewModel.transaction.quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(UnderlinedTextFieldStyle())
                    .font(.headline)
                
                Text("×")
                    .font(.body).bold()
                    .foregroundColor(.gray)
            }
            
            if viewModel.transaction.type == .buy || viewModel.transaction.type == .sell {
                HStack(spacing: .zero) {
                    TextField("Price per Coin", value: $viewModel.transaction.pricePerCoin, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(UnderlinedTextFieldStyle())
                        .font(.headline)
                    
                    Text("$")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            DatePicker("Date", selection: $viewModel.transaction.date, displayedComponents: .date)
                .font(.headline)
            
            HStack {
                Text("Type")
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: $viewModel.transaction.type) {
                    ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .tint(.white)
            }
        }
        .padding()
    }
}

// MARK: - Previews
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
    }
}
