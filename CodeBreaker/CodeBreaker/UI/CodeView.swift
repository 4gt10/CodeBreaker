//
//  CodeView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 19.02.2026.
//

import SwiftUI

struct CodeView<AncillaryView>: View where AncillaryView: View {
    // MARK: Data in
    private let code: Code
    private let kind: CodeBreaker.Kind
    @ViewBuilder private let ancillaryView: () -> AncillaryView
    
    // MARK: Data Shared with me
    @Binding var selection: Int
    
    // MARK: Data Owned by me
    @Namespace private var selectionNamespace
    
    init(
        _ code: Code,
        kind: CodeBreaker.Kind,
        selection: Binding<Int> = .constant(-1),
        @ViewBuilder ancillaryView: @escaping () -> AncillaryView
    ) {
        self.code = code
        self.kind = kind
        self.ancillaryView = ancillaryView
        _selection = selection
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            ForEach(code.pegs.indices, id: \.self) { index in
                PegView(code.pegs[index], kind: kind)
                    .padding(Selection.padding)
                    .background {
                        Group {
                            if selection == index, code.kind == .guess {
                                Selection.shape
                                    .foregroundColor(Selection.color)
                                    .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                                
                            }
                        }
                        .animation(.selection, value: selection)
                    }
                    .overlay {
                        if code.isHidden {
                            Selection.shape.foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        if code.kind == .guess {
                            selection = index
                        }
                    }
            }
            Rectangle()
                .foregroundStyle(.clear)
                .aspectRatio(1, contentMode: .fit)
                .overlay(content: ancillaryView)
        }
    }
}

fileprivate enum Selection {
    static let padding: CGFloat = 4
    static let color = Color.grey(0.7)
    static let shape = Circle()
}

#Preview {
    CodeView(
        .init(
            kind: .masterCode(isHidden: true), pegs: [.missing]),
        kind: .colors,
        selection: .constant(0)
    ) { EmptyView() }
}
