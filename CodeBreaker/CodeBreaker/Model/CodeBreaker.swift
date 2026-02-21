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
        Constant.namedColors[self]
    }
}

struct CodeBreaker {
    enum Kind {
        case colors
        case emojis
        case unknown
        
        static func random(with data: [String]) -> Kind {
            let isColors = data.allSatisfy { $0.color != nil }
            if data.isEmpty {
                return .unknown
            } else if isColors {
                return .colors
            } else {
                return .emojis
            }
        }
    }
    
    static func getRandomPegs(for kind: Kind, count: Int) -> [Peg] {
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
            result = Constant.colorNames
        case .emojis:
            result = Constant.emojiCollections.randomElement() ?? []
        case .unknown:
            return []
        }
        
        return Array(result.prefix(upTo: resultCount))
    }
    
    var kind: Kind = .unknown
    var masterCode: Code = .init(kind: .masterCode, pegs: [])
    var guess: Code = .init(kind: .guess, pegs: [])
    var attempts: [Code] = []
    var pegChoices: [Peg] = []
    
    init(
        kind: Kind = .random(with: Constant.gameCollections.randomElement() ?? []),
        pegsCount: Int = .random(in: Constant.minimumPegsCount...Constant.maximumPegsCount)
    ) {
        restart(kind: kind, pegsCount: pegsCount)
    }
    
    var isOver: Bool {
        attempts.last?.pegs == masterCode.pegs
    }
    
    mutating func restart(
        kind: Kind = .random(with: Constant.gameCollections.randomElement() ?? []),
        pegsCount: Int = .random(in: Constant.minimumPegsCount...Constant.maximumPegsCount)
    ) {
        self.kind = kind
        pegChoices = Self.getRandomPegs(
            for: kind,
            count: Int.random(in: Constant.minimumPegsCount...Constant.maximumPegsCount)
        )
        masterCode = .init(kind: .masterCode, pegs: pegChoices)
        masterCode.randomize(from: pegChoices)
        guess = .init(kind: .guess, pegs: Array(repeating: Peg.missing, count: pegChoices.count))
        attempts = []
    }
    
    mutating func attemptGuess() {
        if attempts.contains(where: { $0.pegs == guess.pegs }) {
            print("Guess error: Already tried this combination")
            return
        }
        if guess.pegs.allSatisfy({ $0 == Peg.missing }) {
            print("Guess error: Pegs not chosen")
            return
        }
        var attempt = guess
        attempt.kind = .attempt(attempt.match(against: masterCode))
        attempts.append(attempt)
        guess.reset()
    }
    
    mutating func changeGuessPeg(at index: Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegInPegChocies = pegChoices.firstIndex(of: existingPeg) {
            let newPeg = pegChoices[(indexOfExistingPegInPegChocies + 1) % pegChoices.count]
            guess.pegs[index] = newPeg
        } else {
            guess.pegs[index] = pegChoices.first ?? Peg.missing
        }
    }
    
    mutating func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        
        guess.pegs[index] = peg
    }
}

private enum Constant {
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
