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
//            if game.isWon {
                view(for: game.masterCode)
//            }
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
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
    
    private func peg(for code: Code, at index: Int) -> some View {
        Circle()
            .overlay {
                if code.pegs[index] == Code.missing {
                    Circle().stroke(Color.gray)
                }
            }
            .contentShape(Circle())
            .foregroundStyle(code.pegs[index])
            .onTapGesture {
                if code.kind == .guess {
                    game.changeGuessPeg(at: index)
                }
            }
    }
    
    private func view(for code: Code) -> some View {
        HStack {
            ForEach(code.pegs.indices, id: \.self) { index in
                peg(for: code, at: index)
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
