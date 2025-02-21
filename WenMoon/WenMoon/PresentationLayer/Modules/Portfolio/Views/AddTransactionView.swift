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
    @State private var selectedCoin: CoinProtocol?
    @State private var showCoinSelectionView = false
    
    private let mode: Mode
    private let didAddTransaction: ((Transaction, CoinProtocol?) -> Void)?
    private let didEditTransaction: ((Transaction) -> Void)?
    
    private var isAddMode: Bool { mode == .add }
    private var isEditMode: Bool { mode == .edit }
    
    // MARK: - Initializers
    init(
        transaction: Transaction = Transaction(),
        mode: Mode = .add,
        selectedCoin: CoinProtocol? = nil,
        didAddTransaction: ((Transaction, CoinProtocol?) -> Void)? = nil,
        didEditTransaction: ((Transaction) -> Void)? = nil
    ) {
        self.transaction = transaction
        self.mode = mode
        self.selectedCoin = selectedCoin
        self.didAddTransaction = didAddTransaction
        self.didEditTransaction = didEditTransaction
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            ZStack {
                Text(isAddMode ? "Add Transaction" : "Edit Transaction")
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
                switch mode {
                case .add:
                    didAddTransaction?(transaction, selectedCoin)
                case .edit:
                    didEditTransaction?(transaction)
                }
                viewModel.triggerImpactFeedback()
                dismiss()
            }) {
                Text(isAddMode ? "Add" : "Edit")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(isAddTransactionButtonDisabled ? .gray.opacity(0.3) : .white)
                    .foregroundColor(isAddTransactionButtonDisabled ? .gray : .black)
                    .cornerRadius(32)
            }
            .disabled(isAddTransactionButtonDisabled)
            
            Spacer()
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isTextFieldFocused = false
                }
        )
        .sheet(isPresented: $showCoinSelectionView) {
            CoinSelectionView(mode: .selection, didSelectCoin: { selectedCoin in
                transaction.coinID = selectedCoin.id
                self.selectedCoin = selectedCoin
            })
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeTransactionFormView(_ transactionBinding: Binding<Transaction>) -> some View {
        VStack(spacing: 16) {
            Button(action: {
                showCoinSelectionView = true
            }) {
                HStack {
                    if let coin = selectedCoin {
                        HStack(spacing: 12) {
                            CoinImageView(
                                imageURL: coin.image,
                                placeholderText: coin.symbol,
                                size: 36
                            )
                            .grayscale(isEditMode ? 1 : .zero)
                            
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
            .disabled(isEditMode)
            
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
