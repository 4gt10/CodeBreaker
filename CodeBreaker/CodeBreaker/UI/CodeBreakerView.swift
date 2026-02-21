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
    @State private var restarting = false
    @State private var hideMostRecentMarkers = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            let kind = game.kind
            if game.isOver {
                CodeView(game.masterCode, kind: kind) {
                    Text("🥳").flexibleFontSize()
                }
            }
            ScrollView {
                if !game.isOver {
                    CodeView(game.guess, kind: kind, selection: $selection) {
                        guessButton
                    }
                    .animation(nil, value: game.attempts.count)
                    .opacity(restarting ? 0 : 1)
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    let code = game.attempts[index]
                    let matches = code.matches
                    let showMarkers = !hideMostRecentMarkers || index != game.attempts.count - 1
                    CodeView(code, kind: kind) {
                        if let matches, showMarkers {
                            MatchMarkers(matches: matches)
                        }
                    }
                    .transition(
                        .attempt(isGameOver: game.isOver)
                    )
                }
            }
            restartButton
            if !game.isOver {
                PegChooserView(
                    choices: game.pegChoices,
                    kind: game.kind,
                    onChoose: changePegAtSelection
                )
                .transition(.pegChooser)
            }
        }
        .padding()
    }
    
    private var guessButton: some View {
        Button("Guess", action: guess)
            .flexibleFontSize()
    }
    
    private var restartButton: some View {
        Button("Restart", systemImage: "arrow.circlepath", action: restart)
    }
    
    private func changePegAtSelection(to peg: Peg) {
        game.setGuessPeg(peg, at: selection)
        selection = (selection + 1) % game.pegChoices.count
    }
    
    private func guess() {
        withAnimation(.guess) {
            game.attemptGuess()
            selection = 0
            hideMostRecentMarkers = true
        } completion: {
            withAnimation(.guess) {
                hideMostRecentMarkers = false
            }
        }
    }
    
    private func restart() {
        withAnimation(.restart) {
            restarting = true
        } completion: {
            withAnimation(.restart) {
                game.restart()
                selection = 0
                restarting = false
            }
        }
    }
}

#Preview {
    CodeBreakerView()
}
