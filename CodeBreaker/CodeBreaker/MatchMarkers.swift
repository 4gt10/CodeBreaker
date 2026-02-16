//
//  MatchMarkers.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftUI

enum Match {
    case exact
    case notExact
    case noMatch
}

struct MatchMarkers: View {
    private let matches: [Match]
    
    init(matches: [Match]) {
        self.matches = matches
    }
    
    var body: some View {
        matchMarkersStacks(rowsPerStack: 2)
    }
    
    @ViewBuilder
    private func matchMarkersStacks(rowsPerStack: Int) -> some View {
        let stacks = matchesStacks(rowsPerStack: rowsPerStack)
        HStack(alignment: .top) {
            ForEach(stacks.indices, id: \.self) { stackIndex in
                let stack = stacks[stackIndex]
                VStack {
                    ForEach(stack, id: \.self) { index in
                        matchMarker(at: index)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func matchMarker(at index: Int) -> some View {
        let exactMatches = matches.filter { $0 == .exact }
        let totalMatches = matches.filter { $0 != .noMatch }
        
        Circle()
            .fill(index < exactMatches.count ? Color.primary : Color.clear)
            .strokeBorder(index < totalMatches.count ? Color.primary : Color.clear, lineWidth: 2)
            .aspectRatio(1, contentMode: .fit)
    }
}

private extension MatchMarkers {
    func matchesStacks(rowsPerStack: Int) -> [[Int]] {
        var result: [[Int]] = []
        var stack: [Int] = []
        for matchIndex in matches.indices {
            if matchIndex > 0, matchIndex % rowsPerStack == 0 {
                result.append(stack)
                stack.removeAll()
            }
            stack.append(matchIndex)
        }
        result.append(stack)
        return result
    }
}

#Preview {
    MatchMarkers(matches: [.exact, .noMatch, .exact, .notExact])
        .padding()
}
