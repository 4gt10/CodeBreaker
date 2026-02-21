//
//  ViewExtensions.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//


import SwiftUI

extension View {
    @ViewBuilder
    func flexibleFontSize(minimumFontSize: CGFloat = 10.0, maximumFontSize: CGFloat = 100.0) -> some View {
        let scaleFactor = minimumFontSize / maximumFontSize
        self
            .font(.system(size: maximumFontSize))
            .minimumScaleFactor(scaleFactor)
    }
}
