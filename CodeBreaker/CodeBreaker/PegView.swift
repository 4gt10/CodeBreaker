//
//  PegView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI

struct PegView: View {
    // MARK: Data in
    private let peg: Peg
    private let kind: CodeBreaker.Kind
    
    init(_ peg: Peg, kind: CodeBreaker.Kind) {
        self.peg = peg
        self.kind = kind
    }
    
    // MARK: - Body
    
    var body: some View {
        pegShape
            .foregroundStyle(.clear)
            .contentShape(pegShape)
            .overlay {
                switch kind {
                case .colors:
                    Circle()
                        .foregroundStyle(peg.color ?? .clear)
                case .emojis:
                    Text(peg)
                        .withMaximumFontSize
                        .scaledToFit()
                case .unknown:
                    Text("❓")
                }
            }
            .overlay {
                if peg == .missing {
                    pegShape.stroke(Color.gray)
                }
            }
    }
    
    private let pegShape = Circle()
}

#Preview {
    PegView(.missing, kind: .colors)
        .padding()
}
