//
//  PlaceholderView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 12.01.25.
//

import SwiftUI

struct PlaceholderView: View {
    // MARK: - Properties
    let text: String

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            Image("moon")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
