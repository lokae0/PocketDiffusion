//
//  NumberEntryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/9/26.
//

import SwiftUI

private extension UI {
    static let numberSize: CGFloat = 36.0
    static let widthScalar: CGFloat = 0.75
    static let fractionLength: Int = 1
    static let minScaleFactor: CGFloat = 0.5

    enum Stepper {
        static let width: CGFloat = 68.0
        static let height: CGFloat = 56.0
    }
}

struct NumberEntryView: View {

    let title: String
    let min: Double
    let max: Double
    var isSliderEnabled: Bool = true
    var isDecimalShown: Bool = false
    var isKeyboardEnabled: Bool = false

    @Binding var number: Double

    @State private var originalNumber: Double = 0

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    @State private var showCancelAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: UI.Spacing.extraLarge) {
                HStack(spacing: UI.Spacing.medium) {
                    let step = isDecimalShown ? 0.1 : 1.0
                    stepperButton(systemImage: UI.Symbol.minus, limit: min) {
                        number -= step
                    }

                    numberTextField

                    stepperButton(systemImage: UI.Symbol.plus, limit: max) {
                        number += step
                    }
                }

                if isSliderEnabled {
                    Slider(value: $number, in: min...max)
                }
            }
            .padding(.horizontal, UI.Spacing.extraLarge)
            .centeredInFrame()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolbarItem
                saveToolBarItem
            }
        }
        .onAppear {
            originalNumber = number
            if isKeyboardEnabled {
                isFocused = true
            }
        }
    }
}

private extension NumberEntryView {

    @ViewBuilder
    var numberTextField: some View {
        let type: UIKeyboardType = isDecimalShown ? .decimalPad : .numberPad
        let format: FloatingPointFormatStyle<Double> = isDecimalShown ?
            .number.precision(.fractionLength((UI.fractionLength))) :
            .number

        TextField("", value: $number, format: format)
            .disabled(isKeyboardEnabled == false)
            .minimumScaleFactor(UI.minScaleFactor)
            .keyboardType(type)
            .font(.system(size: UI.numberSize))
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
        }
    }
}

#Preview {
    @Previewable @State var steps: Double = 25.3

    NumberEntryView(
        title: "Step count",
        min: 0.0,
        max: 100.0,
        isSliderEnabled: true,
        isDecimalShown: true,
        number: $steps
    )
}
