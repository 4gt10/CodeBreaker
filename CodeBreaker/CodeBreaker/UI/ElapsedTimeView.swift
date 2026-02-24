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
    
    init(startTime: Date, endTime: Date?) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var body: some View {
        Group {
            let format = SystemFormatStyle.DateOffset.from(startTime)
            if let endTime {
                Text(endTime, format: format)
            } else {
                Text(TimeDataSource<Date>.currentDate, format: format)
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
    ElapsedTimeView(startTime: .now, endTime: nil)
}
