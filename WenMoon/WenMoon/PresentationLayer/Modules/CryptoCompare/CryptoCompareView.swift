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
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Text("Coming soon...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Compare")
        }
    }
}
