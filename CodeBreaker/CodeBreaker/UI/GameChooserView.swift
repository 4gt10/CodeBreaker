//
//  GameChooserView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 24.02.2026.
//

import SwiftData
import SwiftUI

struct GameChooserView: View {
    // MARK: Data In
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Data Owned by me
    @State private var selectedGame: CodeBreaker?
    @State private var editingGame: CodeBreaker?
    
    // MARK: Data Shared with me
    @Query(sort: \CodeBreaker.name, order: .forward)
    private var games: [CodeBreaker] = []

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
                    selectGame(game)
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
                        Button("Delete") {
                            deleteGame(game)
                        }
                        .tint(.red)
                        Button("Edit") {
                            editingGame = game
                        }
                        .tint(.orange)
                    }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Game", systemImage: "plus", action: createNewGame)
            }
        }
    }

    private func setupGames() {
        let fetchDescriptor = FetchDescriptor<CodeBreaker>(
            predicate: #Predicate { game in true },
            sortBy: [SortDescriptor<CodeBreaker>.init(\.name)]
        )
        do {
            let results = try modelContext.fetch(fetchDescriptor)
            if results.isEmpty {
                modelContext.insert(CodeBreaker(name: "Colors", kind: .colors))
                modelContext.insert(CodeBreaker(name: "Smileys", kind: .with(CodeBreaker.Constant.smileyEmojis)))
                modelContext.insert(CodeBreaker(name: "Animals", kind: .with(CodeBreaker.Constant.animalEmojis)))
                modelContext.insert(CodeBreaker(name: "Cars", kind: .with(CodeBreaker.Constant.carEmojis)))
            }
        } catch let error {
            print("Model context fetch error: \(error.localizedDescription)")
        }
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
        if games.contains(game) {
            modelContext.delete(game)
        }
        modelContext.insert(game)
        selectGame(game)
    }

    private func selectGame(_ game: CodeBreaker) {
        selectedGame?.pauseTimerIfNeeded()
        selectedGame = game
    }

    private func deleteGame(_ gameToDelete: CodeBreaker) {
        modelContext.delete(gameToDelete)

        if selectedGame == gameToDelete {
            self.selectedGame = games.first
        }
    }
}

#Preview {
    GameChooserView()
}
