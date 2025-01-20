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
    let imageSize: CGFloat
    
    init(text: String, imageSize: CGFloat = 24) {
        self.text = text
        self.imageSize = imageSize
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            Image("moon")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.gray)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
