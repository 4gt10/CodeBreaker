//
//  PegChooserView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI

struct PegChooserView: View {
    // MARK: Data in
    private let choices: [Peg]
    private let kind: CodeBreaker.Kind
    private let onChoose: (Peg) -> Void
    
    init(choices: [Peg], kind: CodeBreaker.Kind, onChoose: @escaping (Peg) -> Void) {
        self.choices = choices
        self.kind = kind
        self.onChoose = onChoose
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            ForEach(choices, id: \.self) { peg in
                Button {
                    onChoose(peg)
                } label: {
                    PegView(peg, kind: kind)
                }
            }
        }
    }
}

#Preview {
    PegChooserView(
        choices: [.missing],
        kind: .colors,
        onChoose: { _ in }
    )
}
