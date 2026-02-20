//
//  ViewExtensions.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//


import SwiftUI

extension View {
    @ViewBuilder
    var withMaximumFontSize: some View {
        let minimumFontSize = 10.0
        let maximumFontSize = 100.0
        let scaleFactor = minimumFontSize / maximumFontSize
        self
            .font(.system(size: maximumFontSize))
            .minimumScaleFactor(scaleFactor)
    }
}
