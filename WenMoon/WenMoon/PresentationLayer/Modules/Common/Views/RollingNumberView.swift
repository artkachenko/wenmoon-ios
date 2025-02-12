//
//  RollingNumberView.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 09.02.25.
//

import SwiftUI

struct RollingNumberView: View {
    // MARK: - Properties
    let value: Double?
    let formatter: (Double) -> String
    let font: Font
    let foregroundColor: Color
    
    @State private var previousValue: Double? = nil
    @State private var direction: AnimationDirection = .fromTop
    @State private var isInitialLoad: Bool = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if let value {
                let formattedString = formatter(value)
                HStack(spacing: .zero) {
                    ForEach(Array(formattedString.enumerated()), id: \.offset) { index, char in
                        RollingDigitView(
                            digit: String(char),
                            direction: direction,
                            font: font,
                            foregroundColor: foregroundColor,
                            delay: Double(index) * 0.05,
                            animateOnAppear: (!isInitialLoad && previousValue == nil)
                        )
                    }
                }
            } else {
                Text("-")
                    .font(font)
                    .foregroundColor(foregroundColor)
            }
        }
        .onAppear {
            if let value {
                previousValue = value
            }
            isInitialLoad = false
        }
        .onChange(of: value) { _, newValue in
            if let newValue, let prev = previousValue {
                direction = (newValue >= prev) ? .fromTop : .fromBottom
                previousValue = newValue
            } else if let newValue {
                previousValue = newValue
            }
        }
    }
}

struct RollingDigitView: View {
    // MARK: - Properties
    let digit: String
    let direction: AnimationDirection
    let font: Font
    let foregroundColor: Color
    let delay: Double
    let animateOnAppear: Bool
    
    @State private var offset: CGFloat = .zero
    @State private var opacity: Double = .zero
    @State private var scale: CGFloat = 0.8
    
    private let rollingAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.6)
    
    // MARK: - Body
    var body: some View {
        Text(digit)
            .font(font)
            .foregroundColor(foregroundColor)
            .offset(y: offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                if animateOnAppear {
                    offset = (direction == .fromTop) ? -5 : 5
                    opacity = .zero
                    scale = 0.8
                    withAnimation(rollingAnimation.delay(delay)) {
                        offset = .zero
                        opacity = 1
                        scale = 1
                    }
                } else {
                    offset = .zero
                    opacity = 1
                    scale = 1
                }
            }
            .onChange(of: digit) { oldValue, newValue in
                guard oldValue != newValue else { return }
                offset = (direction == .fromTop) ? -5 : 5
                opacity = .zero
                scale = 0.8
                withAnimation(rollingAnimation.delay(delay)) {
                    offset = .zero
                    opacity = 1
                    scale = 1
                }
            }
    }
}

enum AnimationDirection {
    case fromTop
    case fromBottom
}
