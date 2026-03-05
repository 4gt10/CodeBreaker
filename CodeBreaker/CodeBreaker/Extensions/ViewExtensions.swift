//
//  ViewExtensions.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func flexibleFontSize(minimumFontSize: CGFloat = 10.0, maximumFontSize: CGFloat = 100.0) -> some View {
        let scaleFactor = minimumFontSize / maximumFontSize
        self
            .font(.system(size: maximumFontSize))
            .minimumScaleFactor(scaleFactor)
    }

    func trackTime(for game: CodeBreaker) -> some View {
        modifier(TrackTimeModifier(game: game))
    }
}

private struct TrackTimeModifier: ViewModifier {
    private let game: CodeBreaker

    @Environment(\.scenePhase) private var scenePhase

    init(game: CodeBreaker) {
        self.game = game
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                game.resumeTimerIfNeeded()
            }
            .onDisappear {
                game.pauseTimerIfNeeded()
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    game.resumeTimerIfNeeded()
                case .inactive, .background:
                    game.pauseTimerIfNeeded()
                @unknown default:
                    break
                }
            }
            .onChange(of: game.id) { _, _ in
                game.resumeTimerIfNeeded()
            }
    }
}
