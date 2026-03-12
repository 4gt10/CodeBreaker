//
//  CodeBreakerApp.swift
//  CodeBreaker
//
//  Created by 4gt10 on 14.02.2026.
//

import SwiftData
import SwiftUI

@main
struct CodeBreakerApp: App {
    var body: some Scene {
        WindowGroup {
            GameChooserView()
                .modelContainer(for: CodeBreaker.self)
        }
    }
}
