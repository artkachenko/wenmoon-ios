//
//  SelectionView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.11.24.
//

import SwiftUI

struct SelectionView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedOption: Int
    
    let title: String
    let options: [SettingOption]
    
    // MARK: - Body
    var body: some View {
        VStack {
            ZStack {
                Text(title)
                    .font(.headline)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(.white, Color(.systemGray5))
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
            
            Spacer()
            
            List(options, id: \.self) { option in
                let isSelected = (option.value == selectedOption)
                HStack {
                    HStack(spacing: 12) {
                        if let imageName = option.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        Text(option.title)
                    }
                    .foregroundColor(isSelected ? .white : .gray)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.neonBlue)
                    }
                }
                .listRowBackground(Color.obsidian)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedOption = option.value
                    dismiss()
                }
            }
            .listStyle(.plain)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.obsidian)
    }
}
