//
//  NumberEntryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/9/26.
//

import SwiftUI

private extension UI {
    static let numberSize: CGFloat = 36.0
    static let numberLineWidthScalar: CGFloat = 0.75
    static let heightAdjustment: CGFloat = 6.0

    enum Stepper {
        static let width: CGFloat = 68.0
        static let height: CGFloat = 56.0
    }
}

struct NumberEntryView: View {

    let title: String
    let min: Double
    let max: Double
    let showSlider: Bool = true

    @Binding var number: Double

    @State private var originalNumber: Double = 0

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    @State private var showCancelAlert: Bool = false
    @State private var showEraseAlert: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    HStack(spacing: UI.Spacing.medium) {
                        stepperButton(systemImage: UI.Symbol.minus, limit: min) {
                            number -= 1.0
                        }

                        numberTextField

                        stepperButton(systemImage: UI.Symbol.plus, limit: max) {
                            number += 1.0
                        }
                    }
                    .frame(maxWidth: geometry.size.width * UI.numberLineWidthScalar)
                    .centeredInFrame()
                }
                .frame(maxHeight: geometry.size.height / UI.heightAdjustment)
                .centeredInFrame()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem
                saveToolBarItem
            }
        }
        .onAppear {
            originalNumber = number
            isFocused = true
        }
    }
}

private extension NumberEntryView {

    @ViewBuilder
    var numberTextField: some View {
        TextField("", value: $number, format: .number)
            .keyboardType(.numberPad)
            .font(.system(size: UI.numberSize))
            .tint(.clear)
            .multilineTextAlignment(.center)
            .focused($isFocused)
            .onChange(of: number) { _, newValue in
                if newValue > max {
                    number = max
                } else if newValue < min {
                    number = min
                }
            }
    }

    @ViewBuilder
    func stepperButton(
        systemImage: String,
        limit: Double,
        function: @escaping () -> Void
    ) -> some View {
        Button(action: function) {
            Image(systemName: systemImage)
        }
        .font(.system(size: UI.numberSize, weight: .medium))
        .frame(width: UI.Stepper.width, height: UI.Stepper.height)
        .disabled(number == limit)
        .glassEffect()
    }

    @ToolbarContentBuilder
    var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                if number != originalNumber {
                    showCancelAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Label("Cancel", systemImage: UI.Symbol.xmark)
            }
            .alert("Discard changes?", isPresented: $showCancelAlert) {
                Button(role: .destructive) {
                    number = originalNumber
                    dismiss()
                } label: {
                    Text("Discard")
                }
                Button("Cancel", role: .cancel) {
                    showCancelAlert = false
                }
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
        }
    }
}

#Preview {
    @Previewable @State var steps: Double = 25

    NumberEntryView(
        title: "Step count",
        min: 0.0,
        max: 100.0,
        number: $steps
    )
}
