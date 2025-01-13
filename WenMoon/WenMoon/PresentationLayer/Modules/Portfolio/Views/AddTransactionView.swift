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

    @StateObject private var viewModel = AddTransactionViewModel()

    @FocusState private var isTextFieldFocused: Bool

    @State private var transaction: Transaction
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
        mode = (transaction == nil) ? .add : .edit
        self.transaction = transaction ?? Transaction()
        self.didAddTransaction = didAddTransaction
        self.didEditTransaction = didEditTransaction
    }
    
    // MARK: - Body
    var body: some View {
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
            
            makeTransactionFormView($transaction)
            
            let isAddTransactionButtonDisabled = viewModel.shouldDisableAddTransactionsButton(for: transaction)
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
                    let coin = await viewModel.createCoinData(from: selectedCoin)
                    transaction.coin = coin
                }
            })
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeTransactionFormView(_ transactionBinding: Binding<Transaction>) -> some View {
        VStack(spacing: 16) {
            Button(action: {
                showCoinSelectionView.toggle()
            }) {
                HStack {
                    if let coin = transactionBinding.wrappedValue.coin {
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
                TextField("Quantity", value: transactionBinding.quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(UnderlinedTextFieldStyle())
                    .font(.headline)
                
                Text("×")
                    .font(.body).bold()
                    .foregroundColor(.gray)
            }
            
            if viewModel.isPriceFieldRequired(for: transactionBinding.wrappedValue.type) {
                HStack(spacing: .zero) {
                    TextField("Price per Coin", value: transactionBinding.pricePerCoin, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                        .textFieldStyle(UnderlinedTextFieldStyle())
                        .font(.headline)
                    
                    Text("$")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            DatePicker("Date", selection: transactionBinding.date, displayedComponents: .date)
                .font(.headline)
            
            HStack {
                Text("Type")
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: transactionBinding.type) {
                    ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .tint(.white)
            }
        }
        .padding()
        .onChange(of: transactionBinding.wrappedValue.type) { _, type in
            if !viewModel.isPriceFieldRequired(for: type) {
                transactionBinding.pricePerCoin.wrappedValue = nil
            }
        }
    }
}

// MARK: - Previews
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
    }
}
