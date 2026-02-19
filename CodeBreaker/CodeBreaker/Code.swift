//
//  Code.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//


import SwiftUI

struct Code {
    var kind: Kind
    var pegs: [Peg]
    
    enum Kind: Equatable {
        case masterCode
        case guess
        case attempt([Match])
        case unknown
    }
    
    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegChoices.indices {
            pegs[index] = pegChoices.randomElement() ?? Peg.missing
        }
    }
    
    mutating func reset() {
        let count = pegs.count
        pegs = Array(repeating: .missing, count: count)
    }
    
    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
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
