//
//  CoinImageView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 09.01.25.
//

import SwiftUI

struct CoinImageView: View {
    // MARK: - Properties
    let image: Image?
    let imageURL: URL?
    let imageData: Data?
    let placeholderText: String
    let size: CGFloat
    
    // MARK: - Initializers
    init(
        image: Image? = nil,
        imageURL: URL? = nil,
        imageData: Data? = nil,
        placeholderText: String,
        size: CGFloat
    ) {
        self.image = image
        self.imageURL = imageURL
        self.imageData = imageData
        self.placeholderText = placeholderText
        self.size = size
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            
            if let image {
                makeImage(image)
            } else if let imageData, let uiImage = UIImage(data: imageData) {
                makeImage(Image(uiImage: uiImage))
            } else if let imageURL {
                AsyncImage(url: imageURL, content: { image in
                    makeImage(image)
                }, placeholder: {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(.black)
                })
            } else {
                Text(placeholderText.prefix(1).uppercased())
                    .font(.body)
                    .foregroundColor(.black)
            }
        }
        .brightness(-0.1)
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func makeImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size / 2, height: size / 2)
            .clipShape(Circle())
    }
}
