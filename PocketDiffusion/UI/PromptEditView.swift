//
//  PromptEditView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

struct PromptEditView: View {

    let title: String
    @Binding var text: String
    @State private var originalText: String = ""

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    @State private var showCancelAlert: Bool = false
    @State private var showEraseAlert: Bool = false

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .focused($isFocused)
                .scrollIndicators(.hidden)
                .toolbar {
                    eraseToolbarItem
                    cancelToolbarItem
                    saveToolBarItem
                }
                .padding(UI.Spacing.large)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if text == .promptPlaceholder {
                text = ""
            }
            originalText = text
            isFocused = true
        }
    }
}

private extension PromptEditView {

    @ToolbarContentBuilder
    var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                if text != originalText {
                    showCancelAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Label("Cancel", systemImage: UI.Symbol.xmark)
            }
            .alert("Discard changes?", isPresented: $showCancelAlert) {
                Button(role: .destructive) {
                    text = originalText
                    dismiss()
                } label: {
                    Text("Discard")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ToolbarContentBuilder
    var saveToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                dismiss()
            } label: {
                Label("Save", systemImage: UI.Symbol.checkmark)
            }
            .disabled(text.isEmpty)
        }
    }

    @ToolbarContentBuilder
    var eraseToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                showEraseAlert = true
            } label: {
                Label("Erase", systemImage: UI.Symbol.eraser)
            }
            .disabled(text.isEmpty)
            .alert("Erase all content?", isPresented: $showEraseAlert) {
                Button(role: .destructive) {
                    text = ""
                } label: {
                    Text("Erase")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = .samplePrompt

    PromptEditView(title: "Prompt", text: $text)
}
