//
//  GameSummaryView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 24.02.2026.
//

import SwiftUI

struct GameSummaryView: View {
    // MARK: Data Shared with me
    private let game: CodeBreaker
    
    init(game: CodeBreaker) {
        self.game = game
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(game.name)
                .font(.title)
            PegChooserView(choices: game.pegChoices, kind: game.kind)
                .frame(maxHeight: 44)
            Text("^[\(game.attempts.count) attempt](inflect: true)")
        }
    }
}

#Preview {
    GameSummaryView(game: .init())
}
