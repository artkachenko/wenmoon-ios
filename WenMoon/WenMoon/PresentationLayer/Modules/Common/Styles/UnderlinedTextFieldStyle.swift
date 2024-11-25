//
//  UnderlinedTextFieldStyle.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 29.11.24.
//

import SwiftUI

struct UnderlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .background(
                VStack {
                    Spacer()
                    Color(.gray)
                        .frame(height: 1)
                }
            )
    }
}
