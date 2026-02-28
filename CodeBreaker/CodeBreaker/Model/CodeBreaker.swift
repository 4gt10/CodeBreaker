//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by 4gt10 on 15.02.2026.
//

import SwiftUI

typealias Peg = String

extension Peg {
    static let missing = ""

    var color: Color? {
        CodeBreaker.Constant.namedColors[self] ?? Color(hex: self)
    }
}

@Observable
final class CodeBreaker {
    // MARK: - Types

    enum Kind: Hashable {
        case colors
        case emojis([Peg])
        case unknown

        static func with(_ data: [Peg]) -> Kind {
            let isColors = data.allSatisfy { $0.color != nil }
            if data.isEmpty {
                return .unknown
            } else if isColors {
                return .colors
            } else {
                return .emojis(data)
            }
        }
    }

    enum AttemptGuessError: Error {
        case duplicateGuess
        case incompleteGuess
    }

    // MARK: - Stored Properties

    var name: String
    var kind: Kind = .unknown
    var masterCode: Code = .init(kind: .masterCode(isHidden: true), pegs: [])
    var guess: Code = .init(kind: .guess, pegs: [])
    var attempts: [Code] = []
    var pegChoices: [Peg] = []
    var customColorPegs: [Peg]?
    var startTime: Date = .now
    var endTime: Date?

    // MARK: - Initialization

    init(
        name: String = "CodeBreaker",
        kind: Kind = .with(Constant.gameCollections.randomElement() ?? []),
        pegsCount: Int = .random(in: Constant.minimumPegsCount...Constant.maximumPegsCount)
    ) {
        self.name = name
        restart(kind: kind, pegsCount: pegsCount)
    }

    // MARK: - Derived State

    var isOver: Bool {
        attempts.first?.pegs == masterCode.pegs
    }
}

// MARK: - Game Setup

extension CodeBreaker {
    static func getRandomPegs(for kind: Kind, count: Int, colorPegs: [Peg]? = nil) -> [Peg] {
        let resultCount: Int
        if count < Constant.minimumPegsCount {
            resultCount = Constant.minimumPegsCount
        } else if count > Constant.maximumPegsCount {
            resultCount = Constant.maximumPegsCount
        } else {
            resultCount = count
        }

        let result: [Peg]

        switch kind {
        case .colors:
            result = colorPegs ?? Constant.colorNames
        case .emojis(let pegs):
            result = pegs
        case .unknown:
            return []
        }

        return Array(result.prefix(upTo: resultCount))
    }

    func restart(
        kind: Kind = .with(Constant.gameCollections.randomElement() ?? []),
        pegsCount: Int = .random(in: Constant.minimumPegsCount...Constant.maximumPegsCount)
    ) {
        self.kind = kind.editorSelectionKind

        switch kind.editorSelectionKind {
        case .colors:
            break
        case .emojis:
            customColorPegs = nil
        case .unknown:
            customColorPegs = nil
        }

        pegChoices = Self.getRandomPegs(
            for: self.kind,
            count: pegsCount,
            colorPegs: customColorPegs
        )
        masterCode = .init(kind: .masterCode(isHidden: true), pegs: pegChoices)
        masterCode.randomize(from: pegChoices)
        guess = .init(kind: .guess, pegs: Array(repeating: Peg.missing, count: pegChoices.count))
        attempts = []
        startTime = .now
        endTime = nil
    }
}

// MARK: - Gameplay

extension CodeBreaker {
    func attemptGuess() -> Result<Void, AttemptGuessError> {
        if attempts.contains(where: { $0.pegs == guess.pegs }) {
            return .failure(.duplicateGuess)
        }
        if guess.pegs.contains(where: { $0 == Peg.missing }) {
            return .failure(.incompleteGuess)
        }

        var attempt = guess
        attempt.kind = .attempt(attempt.match(against: masterCode))
        attempts.insert(attempt, at: 0)

        if attempts.count == 1 {
            startTime = .now
        }

        guess.reset()

        if isOver {
            let masterCode = self.masterCode
            self.masterCode = .init(kind: .masterCode(isHidden: false), pegs: masterCode.pegs)
            endTime = .now
        }

        return .success(())
    }

    func changeGuessPeg(at index: Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegInPegChocies = pegChoices.firstIndex(of: existingPeg) {
            let newPeg = pegChoices[(indexOfExistingPegInPegChocies + 1) % pegChoices.count]
            guess.pegs[index] = newPeg
        } else {
            guess.pegs[index] = pegChoices.first ?? Peg.missing
        }
    }

    func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        guess.pegs[index] = peg
    }
}

// MARK: - Editor Logic

extension CodeBreaker {
    static func editorEmojis(from text: String) -> [Peg] {
        var seen = Set<String>()
        var result: [Peg] = []

        for character in text {
            guard character.isEditorEmoji else { continue }
            let emoji = String(character)
            if seen.insert(emoji).inserted {
                result.append(emoji)
            }
            if result.count == Constant.maximumPegsCount {
                break
            }
        }

        return result
    }

    static func sanitizedEmojiEditorText(_ text: String) -> String {
        editorEmojis(from: text).joined(separator: " ")
    }

    static func normalizedGameName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var sortedColorNames: [String] {
        Constant.colorNames.sorted()
    }

    static var defaultEditorColors: [Color] {
        sortedColorNames
            .compactMap { Constant.namedColors[$0] }
            .prefix(Constant.minimumPegsCount)
            .map { $0 }
    }

    static func editorColors(for game: CodeBreaker) -> [Color] {
        let pegs: [Peg]
        switch game.kind.editorSelectionKind {
        case .colors:
            pegs = game.pegChoices
        case .emojis, .unknown:
            pegs = []
        }

        let colors = uniqueEditorColors(pegs.compactMap { $0.color })
        if colors.isEmpty {
            return defaultEditorColors
        }
        return colors
    }

    static func uniqueEditorColors(_ colors: [Color]) -> [Color] {
        var seen = Set<String>()
        var result: [Color] = []

        for color in colors {
            guard let hex = color.hexString else { continue }
            if seen.insert(hex).inserted {
                result.append(color)
            }
        }

        return result
    }

    static func canSaveEditedGame(name: String, kind: Kind, emojiText: String, colors: [Color]) -> Bool {
        let trimmedName = normalizedGameName(name)
        guard !trimmedName.isEmpty else { return false }

        switch kind.editorSelectionKind {
        case .colors:
            let uniqueColorsCount = uniqueEditorColors(colors).count
            return uniqueColorsCount >= Constant.minimumPegsCount && uniqueColorsCount <= Constant.maximumPegsCount
        case .emojis:
            let emojisCount = editorEmojis(from: emojiText).count
            return emojisCount >= Constant.minimumPegsCount
        case .unknown:
            return false
        }
    }

    static func editorEmojiText(for kind: Kind) -> String {
        guard case .emojis(let emojis) = kind else { return "" }
        return emojis.joined(separator: " ")
    }

    static var editorMinimumPegsCount: Int {
        Constant.minimumPegsCount
    }

    static var editorMaximumPegsCount: Int {
        Constant.maximumPegsCount
    }

    static func normalizedEditorColors(_ colors: [Color]) -> [Color] {
        let unique = Array(uniqueEditorColors(colors).prefix(Constant.maximumPegsCount))
        var result = unique

        for defaultColor in defaultEditorColors {
            if result.count >= Constant.minimumPegsCount {
                break
            }

            guard let defaultHex = defaultColor.hexString else { continue }
            let existingHexes = Set(result.compactMap(\.hexString))
            if !existingHexes.contains(defaultHex) {
                result.append(defaultColor)
            }
        }

        return result
    }

    static func addingEditorColor(to colors: [Color]) -> [Color] {
        let normalized = normalizedEditorColors(colors)
        guard normalized.count < Constant.maximumPegsCount else { return normalized }

        let existingHexes = Set(normalized.compactMap(\.hexString))
        for defaultColor in defaultEditorColors {
            guard let defaultHex = defaultColor.hexString else { continue }
            if !existingHexes.contains(defaultHex) {
                return normalized + [defaultColor]
            }
        }

        return normalized + [.white]
    }

    static func removingEditorColor(at index: Int, from colors: [Color]) -> [Color] {
        guard colors.indices.contains(index) else {
            return normalizedEditorColors(colors)
        }

        var updatedColors = colors
        updatedColors.remove(at: index)
        return normalizedEditorColors(updatedColors)
    }

    static func editorColorPegs(from colors: [Color]) -> [Peg] {
        normalizedEditorColors(colors).compactMap { $0.hexString }
    }

    func applyEditorChanges(name: String, kind: Kind, emojiText: String, colors: [Color]) {
        guard Self.canSaveEditedGame(name: name, kind: kind, emojiText: emojiText, colors: colors) else { return }

        self.name = Self.normalizedGameName(name)

        switch kind.editorSelectionKind {
        case .colors:
            let colorPegs = Array(Self.editorColorPegs(from: colors).prefix(Constant.maximumPegsCount))
            customColorPegs = colorPegs
            restart(kind: .colors, pegsCount: colorPegs.count)
        case .emojis:
            let emojis = Array(Self.editorEmojis(from: emojiText).prefix(Constant.maximumPegsCount))
            customColorPegs = nil
            restart(kind: .with(emojis), pegsCount: emojis.count)
        case .unknown:
            break
        }
    }
}

// MARK: - Kind Helpers

extension CodeBreaker.Kind {
    var editorSelectionKind: CodeBreaker.Kind {
        switch self {
        case .colors:
            return .colors
        case .emojis(let pegs):
            return .emojis(pegs)
        case .unknown:
            return .colors
        }
    }

    var isEmojiKind: Bool {
        if case .emojis = self {
            return true
        }
        return false
    }
}

// MARK: - Protocol Conformance

extension CodeBreaker: Identifiable, Hashable, Equatable {
    static func == (lhs: CodeBreaker, rhs: CodeBreaker) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Constants

extension CodeBreaker {
    enum Constant {
        static let minimumPegsCount = 3
        static let maximumPegsCount = 6
        static let namedColors: [String: Color] = [
            "black": .black, "gray": .gray,
            "red": .red, "green": .green, "blue": .blue,
            "orange": .orange, "yellow": .yellow, "pink": .pink,
            "purple": .purple
        ]
        static let colorNames = Array<String>(namedColors.keys)
        static let colors = Array<Color>(namedColors.values)
        static let smileyEmojis: [String] = [
            "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣",
            "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰",
            "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜",
            "🤪", "🤨", "🧐", "🤓", "😎", "🥳", "😏", "😒"
        ]
        static let carEmojis: [String] = [
            "🚗", "🚕", "🚙", "🚌",
            "🚎", "🏎️", "🚓", "🚑",
            "🚒", "🚐", "🚚", "🚛",
            "🚜", "🛵", "🏍️", "🚲"
        ]
        static let animalEmojis: [String] = [
            // Mammals
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐒",
            "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛",
            // Reptiles & Amphibians
            "🐊", "🐢", "🐍", "🦎", "🐸", "🐙",
            // Marine
            "🐠", "🐟", "🐡", "🐬", "🐳", "🐋", "🦈",
            // Insects & Small Critters
            "🐞", "🦋", "🐌", "🐜", "🦟", "🦗", "🕷️", "🕸️", "🐝",
            // Farm & Work Animals
            "🐄", "🐖", "🐏", "🐑", "🐐", "🐪", "🐫", "🦙", "🦒", "🐘", "🦏", "🦛", "🐁", "🐀",
            // Wild Animals
            "🦍", "🦧", "🐆", "🐅", "🐊", "🦓", "🦌", "🦬", "🐃", "🦣", "🦫", "🐫",
            // Birds (more)
            "🦜", "🦢", "🦩", "🕊️", "🐦‍⬛", "🦚", "🦃", "🐓",
            // Sea Creatures (more)
            "🐚", "🪸", "🐠", "🐟",
            // Prehistoric
            "🦕", "🦖"
        ]
        static let emojiCollections: [[String]] = [
            smileyEmojis,
            animalEmojis,
            carEmojis
        ]
        static let gameCollections: [[String]] = [colorNames] + emojiCollections
    }
}

private extension Character {
    var isEditorEmoji: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
}
