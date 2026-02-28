//
//  GameChooserView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 24.02.2026.
//

import SwiftUI

struct GameChooserView: View {
    // MARK: Data Owned by me
    @State private var games: [CodeBreaker] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        GameSummaryView(game: game)
                    }
                }
                .onDelete { offsets in
                    games.remove(atOffsets: offsets)
                }
                .onMove { offsets, destination in
                    games.move(fromOffsets: offsets, toOffset: destination)
                }
            }
            .navigationDestination(for: CodeBreaker.self) { game in
                CodeBreakerView(game: game)
            }
            .listStyle(.plain)
            .toolbar {
                EditButton()
            }
        }
        .onAppear {
            games.append(.init(name: "Colors", kind: .colors))
            games.append(.init(name: "Smileys", kind: .with(CodeBreaker.Constant.smileyEmojis)))
            games.append(.init(name: "Animals", kind: .with(CodeBreaker.Constant.animalEmojis)))
            games.append(.init(name: "Cars", kind: .with(CodeBreaker.Constant.carEmojis)))
        }
    }
}

#Preview {
    GameChooserView()
}
