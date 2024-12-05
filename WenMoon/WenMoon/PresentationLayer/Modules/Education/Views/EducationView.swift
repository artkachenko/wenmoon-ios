//
//  EducationView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import SwiftUI

struct EducationView: View {
    // MARK: - Properties
    @StateObject private var viewModel = EducationViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Text("Coming soon...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Education")
        }
    }
}
