//
//  ColorExtensions.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//


import SwiftUI

extension Color {
    static func grey(_ brightness: CGFloat) -> Color {
        Color(hue: 148/360, saturation: 0, brightness: brightness)
    }
}