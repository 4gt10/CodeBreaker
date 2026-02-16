//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftUI

struct CodeBreakerView: View {
    @State private var game = CodeBreaker()
    
    var body: some View {
        VStack {
            if game.isWon {
                view(for: game.masterCode)
            }
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            Button("Restart") {
                withAnimation {
                    game.restart()
                }
            }
            
        }
        .padding()
    }
    
    private var guessButton: some View {
        Button("Guess") {
            withAnimation {
                game.attemptGuess()
            }
        }
        .withMaximumFontSize
    }
    
    @ViewBuilder
    private func peg(for code: Code, at index: Int) -> some View {
        Circle()
            .foregroundStyle(.clear)
            .overlay {
                switch game.kind {
                case .colors:
                    Circle()
                        .foregroundStyle(code.pegs[index].color ?? .clear)
                case .emojis:
                    Text(code.pegs[index])
                        .withMaximumFontSize
                        .scaledToFit()
                case .unknown:
                    Text("❓")
                }
            }
    }
    
    private func view(for code: Code) -> some View {
        HStack {
            ForEach(code.pegs.indices, id: \.self) { index in
                peg(for: code, at: index)
                    .overlay {
                        if code.pegs[index] == Code.missing {
                            Circle().stroke(Color.gray)
                        }
                    }
                    .contentShape(Circle())
                    .onTapGesture {
                        if code.kind == .guess {
                            game.changeGuessPeg(at: index)
                        }
                    }
            }
            Group {
                switch code.kind {
                case .masterCode:
                    Text("🥳")
                        .withMaximumFontSize
                case .guess:
                    guessButton
                case .attempt(let matches):
                    MatchMarkers(matches: matches)
                default:
                    Spacer()
                }
            }
            .frame(width: 60, height: 60)
        }
    }
}

extension View {
    var withMaximumFontSize: some View {
        self
            .font(.system(size: 80))
            .minimumScaleFactor(0.1)
    }
}

#Preview {
    CodeBreakerView()
}
