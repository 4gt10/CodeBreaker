//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftUI

struct CodeBreakerView: View {
    // MARK: Data Owned by me
    @State private var game = CodeBreaker()
    @State private var selection: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            let kind = game.kind
            if game.isOver {
                CodeView(game.masterCode, kind: kind) {
                    Text("🥳").withMaximumFontSize
                }
            }
            ScrollView {
                if !game.isOver {
                    CodeView(game.guess, kind: kind, selection: $selection) {
                        guessButton
                    }
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    let code = game.attempts[index]
                    let matches = code.matches ?? []
                    CodeView(code, kind: kind) {
                        MatchMarkers(matches: matches)
                    }
                }
            }
            PegChooserView(choices: game.pegChoices, kind: game.kind) { peg in
                game.setGuessPeg(peg, at: selection)
                selection = (selection + 1) % game.pegChoices.count
            }
            restartButton
            
        }
        .padding()
    }
    
    private var guessButton: some View {
        Button("Guess") {
            withAnimation {
                game.attemptGuess()
                selection = 0
            }
        }
        .withMaximumFontSize
    }
    
    private var restartButton: some View {
        Button("Restart") {
            withAnimation {
                game.restart()
            }
        }
    }
}

#Preview {
    CodeBreakerView()
}
