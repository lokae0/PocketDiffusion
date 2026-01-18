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
            originalText = text
            isFocused = true
        }
    }
}

private extension String {
    static let eraseAlertTitle = String(localized: "Erase all content?")
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
                Label(String.Button.cancel, systemImage: UI.Symbol.xmark)
            }
            .alert(String.cancelAlertTitle, isPresented: $showCancelAlert) {
                Button(role: .destructive) {
                    text = originalText
                    dismiss()
                } label: {
                    Text(String.Button.discard)
                }
                Button(String.Button.cancel, role: .cancel) {}
            }
        }
    }

    @ToolbarContentBuilder
    var saveToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                dismiss()
            } label: {
                Label(String.Button.save, systemImage: UI.Symbol.checkmark)
            }
        }
    }

    @ToolbarContentBuilder
    var eraseToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                showEraseAlert = true
            } label: {
                Label(String.Button.erase, systemImage: UI.Symbol.eraser)
            }
            .disabled(text.isEmpty)
            .alert(String.eraseAlertTitle, isPresented: $showEraseAlert) {
                Button(role: .destructive) {
                    text = ""
                } label: {
                    Text(String.Button.erase)
                }
                Button(String.Button.cancel, role: .cancel) {}
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = .Mock.samplePrompt

    PromptEditView(title: "Prompt", text: $text)
}
