//
//  ElapsedTimeView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 22.02.2026.
//

import SwiftUI

struct ElapsedTimeView: View {
    // MARK: Data in
    private let startTime: Date
    private let endTime: Date?
    private let hasStarted: Bool

    init(startTime: Date, endTime: Date?, hasStarted: Bool) {
        self.startTime = startTime
        self.endTime = endTime
        self.hasStarted = hasStarted
    }

    var body: some View {
        Group {
            if hasStarted {
                let format = SystemFormatStyle.DateOffset.from(startTime)
                if let endTime {
                    Text(endTime, format: format)
                } else {
                    Text(TimeDataSource<Date>.currentDate, format: format)
                }
            } else {
                Text("--:--")
            }
        }
        .flexibleFontSize()
        .monospaced()
        .lineLimit(1)
    }
}

private extension SystemFormatStyle.DateOffset {
    static func from(_ date: Date) -> SystemFormatStyle.DateOffset {
        .offset(to: date, allowedFields: [.minute, .second])
    }
}

#Preview {
    ElapsedTimeView(startTime: .now, endTime: nil, hasStarted: false)
}
