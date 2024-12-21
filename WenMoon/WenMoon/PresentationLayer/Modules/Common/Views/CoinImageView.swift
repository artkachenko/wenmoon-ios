//
//  CoinImageView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 09.01.25.
//

import SwiftUI

struct CoinImageView: View {
    let image: Image?
    let imageURL: URL?
    let imageData: Data?
    let placeholder: String
    let size: CGFloat
    
    init(
        image: Image? = nil,
        imageURL: URL? = nil,
        imageData: Data? = nil,
        placeholder: String,
        size: CGFloat
    ) {
        self.image = image
        self.imageURL = imageURL
        self.imageData = imageData
        self.placeholder = placeholder
        self.size = size
    }
    
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
                        .tint(.wmBlack)
                })
            } else {
                Text(placeholder.prefix(1))
                    .font(.body)
                    .foregroundColor(.wmBlack)
            }
        }
        .brightness(-0.1)
    }
    
    @ViewBuilder
    private func makeImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size / 2, height: size / 2)
            .clipShape(Circle())
    }
}
