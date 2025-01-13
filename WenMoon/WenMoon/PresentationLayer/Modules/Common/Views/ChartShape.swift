//
//  ChartShape.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.11.24.
//

import SwiftUI

struct ChartShape: Shape {
    // MARK: - Properties
    var value: Double
    var baseAmplitude: CGFloat = 15
    var frequency: Int = 3
    var maxTilt: CGFloat = 15
    
    // MARK: - Internal Methods
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let midY = rect.midY
        let tilt = CGFloat(value).clamped(to: -maxTilt...maxTilt)
        let segmentWidth = width / CGFloat(frequency)
        path.move(to: CGPoint(x: 0, y: midY))
        
        for i in 0..<frequency {
            let startX = CGFloat(i) * segmentWidth
            let endX = startX + segmentWidth
            let control1 = CGPoint(x: startX + segmentWidth / 4, y: midY - baseAmplitude)
            let control2 = CGPoint(x: startX + 3 * segmentWidth / 4, y: midY + baseAmplitude)
            let endY = midY - (tilt * CGFloat(i + 1) / CGFloat(frequency))
            path.addCurve(to: CGPoint(x: endX, y: endY), control1: control1, control2: control2)
        }
        return path
    }
}
