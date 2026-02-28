//
//  GameEditorView.swift
//  CodeBreaker
//
//  Created by 4gt10 on 28.02.2026.
//

import SwiftUI

struct GameEditorView: View {
    // MARK: Data in
    private let game: CodeBreaker
    private let onSave: () -> Void

    // MARK: Data Owned by me
    @State private var name: String
    @State private var kind: CodeBreaker.Kind
    @State private var emojiText: String
    @State private var colorRows: [Color]

    @Environment(\.dismiss) private var dismiss

    init(game: CodeBreaker, onSave: @escaping () -> Void = {}) {
        self.game = game
        self.onSave = onSave
        _name = State(initialValue: game.name)
        _kind = State(initialValue: game.kind.editorSelectionKind)
        _emojiText = State(initialValue: CodeBreaker.editorEmojiText(for: game.kind))
        _colorRows = State(initialValue: CodeBreaker.editorColors(for: game))
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                kindSection
                kindSpecificSection
            }
            .navigationTitle(Constant.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Constant.cancelButtonTitle, action: dismissEditor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Constant.saveButtonTitle, action: save)
                        .disabled(!canSave)
                }
            }
            .onChange(of: emojiText) { _, newValue in
                emojiText = CodeBreaker.sanitizedEmojiEditorText(newValue)
            }
        }
    }

    private var nameSection: some View {
        Section(Constant.nameSectionTitle) {
            TextField(Constant.namePlaceholder, text: $name)
        }
    }

    private var kindSection: some View {
        Section(Constant.kindSectionTitle) {
            Picker(Constant.kindPickerTitle, selection: kindSelection) {
                Text(Constant.colorsKindTitle).tag(CodeBreaker.Kind.colors)
                Text(Constant.emojisKindTitle).tag(CodeBreaker.Kind.emojis([]))
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private var kindSpecificSection: some View {
        if kind.isEmojiKind {
            emojisSection
        } else {
            colorsSection
        }
    }

    private var colorsSection: some View {
        Section(Constant.colorsSectionTitle) {
            ForEach(colorRows.indices, id: \.self) { index in
                colorRow(at: index)
            }

            Button(Constant.addColorButtonTitle, action: addColorRow)
                .disabled(colorRows.count >= CodeBreaker.editorMaximumPegsCount)
        }
    }

    private func colorRow(at index: Int) -> some View {
        HStack(spacing: Constant.colorRowSpacing) {
            ColorPicker(
                colorLabel(for: index),
                selection: colorBinding(at: index),
                supportsOpacity: false
            )

            Spacer(minLength: 0)

            Button(role: .destructive) {
                removeColorRow(at: index)
            } label: {
                Image(systemName: Constant.removeColorSymbol)
            }
            .disabled(colorRows.count <= CodeBreaker.editorMinimumPegsCount)
        }
    }

    private var emojisSection: some View {
        Section(Constant.emojisSectionTitle) {
            TextEditor(text: $emojiText)
                .frame(minHeight: Constant.emojiEditorMinimumHeight)
                .font(.title2)

            if !parsedEmojis.isEmpty {
                Text(parsedEmojis.joined(separator: Constant.emojiSeparator))
            }
        }
    }

    private var kindSelection: Binding<CodeBreaker.Kind> {
        Binding(
            get: { kind.editorSelectionKind },
            set: { selectedKind in
                kind = selectedKind.editorSelectionKind
            }
        )
    }

    private var parsedEmojis: [String] {
        CodeBreaker.editorEmojis(from: emojiText)
    }

    private var canSave: Bool {
        CodeBreaker.canSaveEditedGame(name: name, kind: kind, emojiText: emojiText, colors: colorRows)
    }

    private func colorBinding(at index: Int) -> Binding<Color> {
        Binding(
            get: {
                guard colorRows.indices.contains(index) else { return .clear }
                return colorRows[index]
            },
            set: { selectedColor in
                guard colorRows.indices.contains(index) else { return }
                var updatedColors = colorRows
                updatedColors[index] = selectedColor
                colorRows = CodeBreaker.normalizedEditorColors(updatedColors)
            }
        )
    }

    private func addColorRow() {
        colorRows = CodeBreaker.addingEditorColor(to: colorRows)
    }

    private func removeColorRow(at index: Int) {
        colorRows = CodeBreaker.removingEditorColor(at: index, from: colorRows)
    }

    private func colorLabel(for index: Int) -> String {
        "\(Constant.colorRowTitle) \(index + 1)"
    }

    private func save() {
        game.applyEditorChanges(name: name, kind: kind, emojiText: emojiText, colors: colorRows)
        onSave()
        dismiss()
    }

    private func dismissEditor() {
        dismiss()
    }
}

private extension GameEditorView {
    enum Constant {
        static let navigationTitle = "Edit Game"
        static let cancelButtonTitle = "Cancel"
        static let saveButtonTitle = "Save"

        static let nameSectionTitle = "Name"
        static let namePlaceholder = "Game name"

        static let kindSectionTitle = "Game Kind"
        static let kindPickerTitle = "Kind"
        static let colorsKindTitle = "Colors"
        static let emojisKindTitle = "Emojis"

        static let colorsSectionTitle = "Colors"
        static let emojisSectionTitle = "Emojis"

        static let addColorButtonTitle = "Add Color"
        static let removeColorSymbol = "minus.circle.fill"
        static let colorRowTitle = "Color"
        static let colorRowSpacing: CGFloat = 12

        static let emojiEditorMinimumHeight: CGFloat = 120
        static let emojiSeparator = " "
    }
}

#Preview {
    GameEditorView(game: .init())
}
