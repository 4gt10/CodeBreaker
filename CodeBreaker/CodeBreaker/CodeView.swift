//
//  CodeView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI

struct CodeView: View {
    // MARK: Data in
    private let code: Code
    private let game: CodeBreaker
    
    // MARK: Data Shared with me
    @Binding var selection: Int
    
    init(_ code: Code, game: CodeBreaker, selection: Binding<Int>) {
        self.code = code
        self.game = game
        _selection = selection
    }
    
    // MARK: - Body
    
    var body: some View {
        ForEach(code.pegs.indices, id: \.self) { index in
            PegView(code.pegs[index], kind: game.kind)
                .padding(Selection.padding)
                .background {
                    if selection == index, code.kind == .guess {
                        Selection.shape
                            .foregroundColor(Selection.color)
                    }
                }
                .onTapGesture {
                    if code.kind == .guess {
                        selection = index
                    }
                }
        }
    }
    
    enum Selection {
        static let padding: CGFloat = 4
        static let color = Color.grey(0.6)
        static let shape = Circle()
    }
}

#Preview {
    CodeView(
        .init(
            kind: .masterCode, pegs: [.missing]),
        game: .init(),
        selection: .constant(0)
    )
}
