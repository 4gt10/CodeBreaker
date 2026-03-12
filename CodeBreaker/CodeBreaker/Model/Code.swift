//
//  Code.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//


import SwiftData
import SwiftUI

typealias Match = Code.Kind.Match

@Model
final class Code {
    var _kind: String
    var pegs: [Peg]
    var timestamp = Date.now
    
    var kind: Kind {
        get { Kind(_kind) }
        set { _kind = newValue.description }
    }
    
    enum Kind: Equatable {
        case masterCode(isHidden: Bool)
        case guess
        case attempt([Match])
        case unknown
        
        enum Match {
            case exact
            case notExact
            case noMatch
        }
    }
    
    var isHidden: Bool {
        switch kind {
        case .masterCode(let isHidden): isHidden
        default: false
        }
    }
    
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }
    
    init(kind: Kind, pegs: [Peg]) {
        self._kind = kind.description
        self.pegs = pegs
    }
    
    func randomize(from pegChoices: [Peg]) {
        for index in pegChoices.indices {
            pegs[index] = pegChoices.randomElement() ?? Peg.missing
        }
    }
    
    func reset() {
        let count = pegs.count
        pegs = Array(repeating: .missing, count: count)
    }
    
    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs
        let backwardsExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return .noMatch
            }
        }
        let exactMatches = Array(backwardsExactMatches.reversed())
        return pegs.indices.map { index in
            if let matchIndex = pegsToMatch.firstIndex(of: pegs[index]),
               exactMatches[index] != .exact {
                pegsToMatch.remove(at: matchIndex)
                return .notExact
            } else {
                return exactMatches[index]
            }
        }
    }
}
// MARK: - Kind String Conversion

extension Code.Kind: LosslessStringConvertible {
    var description: String {
        switch self {
        case .masterCode(let isHidden):
            return "masterCode:\(isHidden)"
        case .guess:
            return "guess"
        case .attempt(let matches):
            let encoded = matches.map { $0.description }.joined(separator: ",")
            return "attempt:\(encoded)"
        case .unknown:
            return "unknown"
        }
    }

    init(_ description: String) {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()

        if lowercased == "guess" {
            self = .guess
            return
        }

        if lowercased == "unknown" {
            self = .unknown
            return
        }

        if lowercased.hasPrefix("mastercode:") {
            let value = trimmed.dropFirst("masterCode:".count)
            let boolString = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if boolString == "true" {
                self = .masterCode(isHidden: true)
                return
            }
            if boolString == "false" {
                self = .masterCode(isHidden: false)
                return
            }
            self = .unknown
            return
        }

        if lowercased.hasPrefix("attempt:") {
            let value = trimmed.dropFirst("attempt:".count)
            let rawMatches = value.split(separator: ",", omittingEmptySubsequences: true)
            let matches = rawMatches.compactMap { Code.Kind.Match(String($0)) }
            if matches.count == rawMatches.count {
                self = .attempt(matches)
                return
            }
            self = .unknown
            return
        }

        self = .unknown
        return
    }
}

extension Code.Kind.Match: LosslessStringConvertible {
    var description: String {
        switch self {
        case .exact: return "exact"
        case .notExact: return "notExact"
        case .noMatch: return "noMatch"
        }
    }

    init?(_ description: String) {
        switch description.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "exact": self = .exact
        case "notexact": self = .notExact
        case "nomatch": self = .noMatch
        default: return nil
        }
    }
}

