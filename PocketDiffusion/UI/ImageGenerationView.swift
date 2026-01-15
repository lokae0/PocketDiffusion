//
//  ImageGenerationView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 512.0

    enum DoneIndicator {
        static let size: CGFloat = 24.0
        static let shadowRadius: CGFloat = 1.0

        static func frameSize(parentSize: CGSize) -> CGSize {
            let scalar = 0.85
            return .init(
                width: parentSize.width * scalar,
                height: parentSize.height * scalar
            )
        }
    }
    enum CurrentStep {
        static let horizontalPadding: CGFloat = -20.0
        static let verticalPadding: CGFloat = -5.0
    }
}

struct ImageGenerationView: View {

    @Binding var imageStore: GeneratedImageStoring

    private var isGenInProgress: Bool {
        imageStore.state == .waiting || imageStore.state == .receiving
    }

    @State private var previewImageSize: CGSize = .zero
    @State private var shownModal: Modal?
    @State private var isCancelAlertShown: Bool = false

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
                        .centeredInFrame()
                }

                Section {
                    let prompt = imageStore.prompt
                    let promptValue = prompt.isEmpty ? .promptPlaceholder : prompt
                    labeledContent(for: .prompt, value: promptValue)

                    let negativePrompt = imageStore.negativePrompt
                    let negativePromptValue = negativePrompt.isEmpty ? .promptPlaceholder : negativePrompt
                    labeledContent(for: .negativePrompt, value: negativePromptValue)

                    labeledContent(for: .stepCount, value: String(imageStore.stepCount))

                    let guidanceFormat = String(format: "%.1f", arguments: [imageStore.guidanceScale])
                    labeledContent(for: .guidanceScale, value: guidanceFormat)

                    Toggle("Randomize seed", isOn: $imageStore.isSeedRandom)
                        .tint(UI.tintColor)

                    if !imageStore.isSeedRandom {
                        labeledContent(for: .seed, value: String(imageStore.seed))
                    }
                }
            }
            .scrollIndicators(.hidden)
            .sheet(
                item: $shownModal,
                content: content(for:)
            )

            primaryAction
                .padding(.bottom, UI.Spacing.large)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
        }
        .alert(
            imageStore.errorInfo?.title ?? "Oh no",
            isPresented: .isPresent($imageStore.errorInfo),
            presenting: imageStore.errorInfo
        ) { _ in
            // Default 'OK' button is included
        } message: { info in
            Text(info.message)
        }
    }
}

private extension ImageGenerationView {

    @ViewBuilder
    var primaryAction: some View {
        let cancelAction = {
            // Allow immediate cancellation during prewarming
            if imageStore.state == .waiting {
                imageStore.cancelImageGeneration()
            } else {
                isCancelAlertShown = true
            }
        }
        Button(
            isGenInProgress ? "Cancel" : "Generate",
            role: nil,
            action: isGenInProgress ? cancelAction : imageStore.generateImages
        )
        .controlSize(.large)
        .buttonStyle(.glass)
        .tint(isGenInProgress ? nil : UI.tintColor)
        .alert("Are you sure you want to cancel generating?", isPresented: $isCancelAlertShown) {
            Button("Confirm", role: .destructive) {
                imageStore.cancelImageGeneration()
            }
            Button("Nevermind", role: .cancel) {}
        }
        .onChange(of: imageStore.state) { oldValue, newValue in
            // Hide the alert if generation finishes before user input is received
            if oldValue == .receiving && newValue == .done {
                isCancelAlertShown = false
            }
        }
    }

    @ViewBuilder
    var previewImage: some View {
        ZStack {
            Image(uiImage: imageStore.previewImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(UI.cornerRadius)
                .frame(maxWidth: UI.imageHeight, maxHeight: UI.imageHeight)
                .onGeometryChange(for: CGSize.self) { proxy in
                    return proxy.size
                } action: { newSize in
                    previewImageSize = newSize
                }

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

            let frameSize = UI.DoneIndicator.frameSize(parentSize: previewImageSize)
            if imageStore.state == .receiving, let currentStep = imageStore.currentStep {
                Text("Steps completed: \(currentStep + 1) of \(imageStore.stepCount)")
                    .font(.system(.footnote))
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .cornerRadius(UI.cornerRadius)
                            .padding(.horizontal, UI.CurrentStep.horizontalPadding)
                            .padding(.vertical, UI.CurrentStep.verticalPadding)
                    )
                    .frame(
                        width: frameSize.width,
                        height: frameSize.height,
                        alignment: .top
                    )
            }

            if imageStore.state == .done {
                VStack(alignment: .trailing) {
                    Image(systemName: UI.Symbol.checkmarkCircleFill)
                        .font(.system(size: UI.DoneIndicator.size))
                        .foregroundStyle(UI.tintColor)
                        .background(.white)
                        .cornerRadius(UI.DoneIndicator.size)
                        .transition(.symbolEffect)

                    if let duration = imageStore.storedImages.last?.durationString {
                        Text(duration)
                            .padding(.top, UI.Spacing.extraSmall)
                    }
                }
                .shadow(radius: UI.DoneIndicator.shadowRadius)
                .frame(
                    width: frameSize.width,
                    height: frameSize.height,
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
                text: $imageStore.prompt
            )
        case .negativePrompt:
            PromptEditView(
                title: Modal.negativePrompt.title,
                text: $imageStore.negativePrompt
            )
        case .stepCount:
            NumberEntryView(
                title: Modal.stepCount.title,
                min: 1.0,
                max: 50.0,
                number: .fromInt($imageStore.stepCount)
            )
        case .guidanceScale:
            NumberEntryView(
                title: Modal.guidanceScale.title,
                min: 1.0,
                max: 20.0,
                isDecimalShown: true,
                number: $imageStore.guidanceScale
            )
        case .seed:
            NumberEntryView(
                title: Modal.seed.title,
                min: 0.0,
                max: Double(UInt32.max),
                isSliderEnabled: false,
                isKeyboardEnabled: true,
                number: .fromInt($imageStore.seed)
            )
        }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore(
        isErrorShown: true
    )
    ImageGenerationView(imageStore: $previewImageStore)
}
