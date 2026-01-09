//
//  ImageGenerationView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 400.0

    enum DoneIndicator {
        static let size: CGFloat = 24.0
        static let shadowRadius: CGFloat = 1.0

        static var frameSize: CGFloat {
            imageHeight * 6/7
        }
    }
}

struct ImageGenerationView: View {

    @Binding var imageStore: GeneratedImageStoring

    // TODO: remove once it's working
    private let debugShowCancelButton = false

    private var isGenInProgress: Bool {
        imageStore.state == .waiting || imageStore.state == .receiving
    }

    @AppStorage("prompt") private var prompt: String = .promptPlaceholder
    @AppStorage("negativePrompt") private var negativePrompt: String = .promptPlaceholder
    @AppStorage("stepCount") private var stepCount: Int = 25
    @AppStorage("guidanceScale") private var guidanceScale: Double = 11
    @AppStorage("seed") private var seed: Int = 0
    @AppStorage("isSeedRandom") private var isSeedRandom: Bool = true

    @State private var shownModal: Modal?

    private enum Modal: String, Identifiable {
        case prompt
        case negativePrompt
        case stepCount
        case guidanceScale
        case seed

        var title: String {
            switch self {
            case .prompt: "Prompt"
            case .negativePrompt: "Negative prompt"
            case .stepCount: "Step count"
            case .guidanceScale: "Guidance scale"
            case .seed: "Seed"
            }
        }

        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Form {
                Section {
                    previewImage
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }

                Section {
                    labeledContent(for: .prompt, value: prompt)
                    labeledContent(for: .negativePrompt, value: negativePrompt)
                    labeledContent(for: .stepCount, value: String(stepCount))

                    let guidanceFormat = String(format: "%.1f", arguments: [guidanceScale])
                    labeledContent(for: .guidanceScale, value: guidanceFormat)

                    Toggle("Randomize seed", isOn: $isSeedRandom)
                        .tint(UI.tintColor)

                    if !isSeedRandom {
                        labeledContent(for: .seed, value: String(seed))
                    }
                }
            }
            .scrollIndicators(.hidden)
            .sheet(
                item: $shownModal,
                onDismiss: {
                    withAnimation(.easeInOut) { handleEmptyPrompts() }
                },
                content: content(for:)
            )

            HStack {
                generatorButton

                if isGenInProgress && debugShowCancelButton {
                    cancelButton
                }
            }
            .padding(.bottom, UI.Spacing.large)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottom
            )
        }
    }

    private func handleEmptyPrompts() {
        if prompt.isEmpty {
            prompt = .promptPlaceholder
        }
        if negativePrompt.isEmpty {
            negativePrompt = .promptPlaceholder
        }
    }
}

private extension ImageGenerationView {

    @ViewBuilder
    var generatorButton: some View {
        let title = isGenInProgress ? "In progress..." : "Generate"

        Button(title, role: nil) {
            imageStore.generateImages(
                with: GenerationParameters(
                    prompt: prompt == .promptPlaceholder ? "" : prompt,
                    negativePrompt: negativePrompt == .promptPlaceholder ? "" : prompt,
                    stepCount: stepCount,
                    guidanceScale: guidanceScale,
                    seed: isSeedRandom ? UInt32.random(in: 0..<UInt32.max) : UInt32(seed),
                )
            )
        }
        .disabled(isGenInProgress)
        .controlSize(.large)
        .buttonStyle(.glass)
        .tint(UI.tintColor)
    }

    @ViewBuilder
    var cancelButton: some View {
        Button("Cancel", role: .destructive) {
            imageStore.cancelImageGeneration()
        }
        .controlSize(.large)
        .buttonStyle(.glass)
    }

    @ViewBuilder
    var previewImage: some View {
        ZStack {
            Image(uiImage: imageStore.previewImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(UI.cornerRadius)
                .frame(height: UI.imageHeight)

            let loadingMessage = [
                "Reticulating splines...",
                "Stealing artist content...",
                "Don't get mad at the AI, it won't forget you",
                "Changing Neural Engine oil...",
                "Implementing Polydactyly...",
                "Grilling up extra hot dog fingers...",
                "Attaching limbs to inappropriate places...",
            ].randomElement() ?? ""

            if imageStore.state == .waiting {
                ProgressView(loadingMessage)
                    .progressViewStyle(CircularProgressViewStyle())
                    .centeredInFrame()
            }
            if imageStore.state == .done {
                Image(systemName: UI.Symbol.checkmarkCircleFill)
                    .font(.system(size: UI.DoneIndicator.size))
                    .foregroundStyle(UI.tintColor)
                    .background(.white)
                    .cornerRadius(UI.DoneIndicator.size)
                    .shadow(radius: UI.DoneIndicator.shadowRadius)
                    .transition(.symbolEffect)
                    .frame(
                        maxWidth: UI.DoneIndicator.frameSize,
                        maxHeight: UI.DoneIndicator.frameSize,
                        alignment: .topTrailing
                    )
            }
        }
    }

    @ViewBuilder
    private func labeledContent(for modal: Modal, value: String) -> some View {
        LabeledContent(modal.title, value: value)
            .lineLimit(2)
            .contentShape(Rectangle())
            .onTapGesture {
                shownModal = modal
            }
    }

    @ViewBuilder
    private func content(for modal: Modal) -> some View {
        switch modal {
        case .prompt:
            PromptEditView(
                title: Modal.prompt.title,
                text: $prompt
            )
        case .negativePrompt:
            PromptEditView(
                title: Modal.negativePrompt.title,
                text: $negativePrompt
            )
        case .stepCount:
            let stepDouble = Binding<Double>(
                get: { Double($stepCount.wrappedValue) },
                set: { $stepCount.wrappedValue = Int($0) })

            NumberEntryView(
                title: Modal.stepCount.title,
                min: 1.0,
                max: 50.0,
                number: stepDouble
            )
        case .guidanceScale:
            NumberEntryView(
                title: Modal.guidanceScale.title,
                min: 1.0,
                max: 20.0,
                isDecimalShown: true,
                number: $guidanceScale
            )
        case .seed:
            let seedDouble = Binding<Double>(
                get: { Double($seed.wrappedValue) },
                set: { $seed.wrappedValue = Int($0) })

            NumberEntryView(
                title: Modal.seed.title,
                min: 0.0,
                max: Double(UInt32.max),
                isSliderEnabled: false,
                isKeyboardEnabled: true,
                number: seedDouble
            )
        }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGenerationView(imageStore: $previewImageStore)
}
