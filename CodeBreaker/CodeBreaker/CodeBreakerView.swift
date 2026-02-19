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
            if game.isOver {
                view(for: game.masterCode)
            }
            ScrollView {
                if !game.isOver {
                    view(for: game.guess)
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
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
    
    private func view(for code: Code) -> some View {
        HStack {
            CodeView(code, game: game, selection: $selection)
            Rectangle()
                .foregroundStyle(.clear)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    switch code.kind {
                    case .masterCode:
                        Text("🥳").withMaximumFontSize
                    case .guess:
                        guessButton
                    case .attempt(let matches):
                        MatchMarkers(matches: matches)
                    default:
                        Spacer()
                    }
                }
        }
    }
}

#Preview {
    CodeBreakerView()
}
