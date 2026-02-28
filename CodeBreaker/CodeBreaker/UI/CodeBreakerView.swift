//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftUI

struct CodeBreakerView: View {
    // MARK: Data Shared with me
    private let game: CodeBreaker
    
    // MARK: Data Owned by me
    @State private var selection: Int = 0
    @State private var restarting = false
    @State private var hideMostRecentMarkers = false
    
    init(game: CodeBreaker) {
        self.game = game
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            let kind = game.kind
            CodeView(game.masterCode, kind: kind)
            ScrollView {
                if !game.isOver {
                    CodeView(game.guess, kind: kind, selection: $selection) {
                        guessButton
                    }
                    .animation(nil, value: game.attempts.count)
                    .opacity(restarting ? 0 : 1)
                }
                ForEach(game.attempts, id: \.pegs) { attempt in
                    let code = attempt
                    let matches = code.matches
                    let showMarkers = !hideMostRecentMarkers || attempt.pegs != game.attempts.first?.pegs
                    CodeView(code, kind: kind) {
                        if let matches, showMarkers {
                            MatchMarkersView(matches: matches)
                        }
                    }
                    .transition(
                        .attempt(isGameOver: game.isOver)
                    )
                }
            }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                restartButton
            }
            ToolbarItem {
                ElapsedTimeView(startTime: game.startTime, endTime: game.endTime)
            }
        }
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
            restarting = game.isOver
            game.restart(kind: game.kind)
            selection = 0
        } completion: {
            withAnimation(.restart) {
                restarting = false
            }
        }
    }
}

#Preview {
    CodeBreakerView(game: .init())
}
