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
    @State private var showCelebration = false
    @State private var guessShakeTrigger = 0

    init(game: CodeBreaker) {
        self.game = game
    }

    // MARK: - Body

    var body: some View {
        VStack {
            let kind = game.kind
            CodeView(game.masterCode, kind: kind) {
                if showCelebration {
                    CelebrationEmojiView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
            ScrollView {
                if !game.isOver {
                    CodeView(game.guess, kind: kind, selection: $selection) {
                        guessButton
                    }
                    .modifier(ShakeEffect(animatableData: CGFloat(guessShakeTrigger)))
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
        .frame(maxWidth: Layout.maxContentWidth)
        .frame(maxWidth: .infinity)
        .padding()
        .navigationTitle(game.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                restartButton
            }
            ToolbarItem {
                ElapsedTimeView(
                    startTime: game.startTime,
                    endTime: game.endTime,
                    hasStarted: !game.attempts.isEmpty
                )
            }
        }
        .onAppear {
            showCelebration = game.isOver
        }
        .onChange(of: game.isOver) { _, isOver in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                showCelebration = isOver
            }
        }
        .onChange(of: game.id) { _, _ in
            selection = 0
            showCelebration = game.isOver
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
        switch game.attemptGuess() {
        case .success:
            withAnimation(.guess) {
                selection = 0
                hideMostRecentMarkers = true
            } completion: {
                withAnimation(.guess) {
                    hideMostRecentMarkers = false
                }
            }
        case .failure:
            withAnimation(.easeInOut(duration: 0.45)) {
                guessShakeTrigger += 1
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

private struct CelebrationEmojiView: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            Text("🥳")
                .font(.system(size: side * 0.78))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(animate ? 1.12 : 0.92)
                .rotationEffect(.degrees(animate ? 8 : -8))
                .offset(y: animate ? -2 : 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
            ) {
                animate = true
            }
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translationX = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translationX, y: 0))
    }
}

private extension CodeBreakerView {
    enum Layout {
        static let maxContentWidth: CGFloat = 760
    }
}

#Preview {
    CodeBreakerView(game: .init())
}
