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
    @State private var selectedGame: CodeBreaker?
    @State private var editingGame: CodeBreaker?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                compactBody
            } else {
                regularBody
            }
        }
        .sheet(item: $editingGame) { game in
            GameEditorView(game: game) {
                handleSave(for: game)
            }
        }
        .onAppear(perform: setupGames)
    }

    private var compactBody: some View {
        NavigationStack {
            gameList { game in
                NavigationLink(value: game) {
                    GameSummaryView(game: game)
                }
            }
            .navigationDestination(for: CodeBreaker.self) { game in
                CodeBreakerView(game: game)
            }
        }
    }

    private var regularBody: some View {
        NavigationSplitView {
            gameList { game in
                Button {
                    selectedGame = game
                } label: {
                    GameSummaryView(game: game)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        } detail: {
            if let selectedGame {
                CodeBreakerView(game: selectedGame)
            } else {
                ContentUnavailableView("Select a game", systemImage: "gamecontroller")
            }
        }
    }

    private func gameList<Row: View>(@ViewBuilder row: @escaping (CodeBreaker) -> Row) -> some View {
        List {
            ForEach(games) { game in
                row(game)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Edit") {
                            editingGame = game
                        }
                        .tint(.orange)
                    }
            }
            .onDelete(perform: deleteGames)
            .onMove { offsets, destination in
                games.move(fromOffsets: offsets, toOffset: destination)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Game", systemImage: "plus", action: createNewGame)
            }
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
        }
    }

    private func setupGames() {
        guard games.isEmpty else { return }

        games = [
            .init(name: "Colors", kind: .colors),
            .init(name: "Smileys", kind: .with(CodeBreaker.Constant.smileyEmojis)),
            .init(name: "Animals", kind: .with(CodeBreaker.Constant.animalEmojis)),
            .init(name: "Cars", kind: .with(CodeBreaker.Constant.carEmojis))
        ]

        selectedGame = games.first
    }

    private func createNewGame() {
        let newGame = CodeBreaker(
            name: "New Game",
            kind: .colors,
            pegsCount: CodeBreaker.editorMinimumPegsCount
        )
        editingGame = newGame
    }

    private func handleSave(for game: CodeBreaker) {
        if !games.contains(game) {
            games.insert(game, at: 0)
        }
        selectedGame = game
    }

    private func deleteGames(at offsets: IndexSet) {
        let removedGames = offsets.map { games[$0] }
        games.remove(atOffsets: offsets)

        if let selectedGame, removedGames.contains(selectedGame) {
            self.selectedGame = games.first
        }
    }
}

#Preview {
    GameChooserView()
}
