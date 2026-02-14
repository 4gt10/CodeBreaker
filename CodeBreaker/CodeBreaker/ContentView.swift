//
//  ContentView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            pegs(colors: [.red, .green, .blue, .yellow])
            pegs(colors: [.green, .green, .red, .blue])
            pegs(colors: [.red, .green, .blue, .blue,])
        }
        .padding()
    }
    
    func pegs(colors: [Color]) -> some View {
        HStack {
            ForEach(colors.indices, id: \.self) { index in
                Circle()
                    .foregroundStyle(colors[index])
            }
            MatchMarkers(matches: [.exact, .notExact, .noMatch, .exact])
        }
    }
}

#Preview {
    ContentView()
}
