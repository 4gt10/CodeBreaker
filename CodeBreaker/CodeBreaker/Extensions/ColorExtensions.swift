//
//  ColorExtensions.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI
import UIKit

extension Color {
    static func grey(_ brightness: CGFloat) -> Color {
        Color(hue: 148 / 360, saturation: 0, brightness: brightness)
    }

    init?(hex: String) {
        var hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexValue.hasPrefix("#") {
            hexValue.removeFirst()
        }

        guard hexValue.count == 6, let rgb = Int(hexValue, radix: 16) else {
            return nil
        }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self = Color(red: red, green: green, blue: blue)
    }

    var hexString: String? {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let redInt = Int((red * 255.0).rounded())
        let greenInt = Int((green * 255.0).rounded())
        let blueInt = Int((blue * 255.0).rounded())

        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
}
