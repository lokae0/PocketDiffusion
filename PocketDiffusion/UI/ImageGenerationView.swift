//
//  ImageGenerationView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 512.0
    static let labeledContentLineLimit: Int = 2

    static let stepCountMin: Double = 1.0
    static let stepCountMax: Double = 50.0

    static let guidanceScaleMin: Double = 1.0
    static let guidanceScaleMax: Double = 20.0

    static let seedMin: Double = 0.0
    static let seedMax = Double(UInt32.max)

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

private extension String {
    static let randomizeSeed = String(localized: "Randomize seed")

    static let cancelConfirmation = String(
        localized: "Are you sure you want to cancel generating?"
    )

    static let loadingMessages = [
        String(localized: "Reticulating splines..."),
        String(localized: "Stealing artist content..."),
        String(localized: "Don't get mad at the AI, it won't forget you"),
        String(localized: "Changing Neural Engine oil..."),
        String(localized: "Implementing Polydactyly..."),
        String(localized: "Grilling up extra hot dog fingers..."),
        String(localized: "Attaching limbs to inappropriate places..."),
    ]

    static func steps(completed: Int, stepCount: Int) -> Self {
        .init(localized: "Steps completed: \(completed) of \(stepCount)")
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
    @State private var isZoomableImageShown: Bool = false

    private enum Modal: String, Identifiable {
        case prompt
        case negativePrompt
        case stepCount
        case guidanceScale
        case seed

        var title: String {
            switch self {
            case .prompt: String.Settings.prompt
            case .negativePrompt: String.Settings.negativePrompt
            case .stepCount: String.Settings.stepCount
            case .guidanceScale: String.Settings.guidanceScale
            case .seed: String.Settings.seed
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

                    let guidanceFormat = String.format(guidanceScale: imageStore.guidanceScale)
                    labeledContent(for: .guidanceScale, value: guidanceFormat)

                    Toggle(String.randomizeSeed, isOn: $imageStore.isSeedRandom)
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
            .fullScreenCover(isPresented: $isZoomableImageShown) {
                ModalZoomableImageView(uiImage: imageStore.previewImage)
            }

            primaryAction
                .padding(.bottom, UI.Spacing.large)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
        }
        .errorInfoAlert(for: $imageStore)
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
            isGenInProgress ? String.Button.cancel : String.Button.generate,
            role: nil,
            action: isGenInProgress ? cancelAction : imageStore.generateImages
        )
        .controlSize(.large)
        .buttonStyle(.glass)
        .tint(isGenInProgress ? nil : UI.tintColor)
        .alert(String.cancelConfirmation, isPresented: $isCancelAlertShown) {
            Button(String.Button.confirm, role: .destructive) {
                imageStore.cancelImageGeneration()
            }
            Button(String.Button.nevermind, role: .cancel) {}
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
                .onTapGesture {
                    isZoomableImageShown = true
                }

            let loadingMessage = String.loadingMessages.randomElement() ?? ""
            if imageStore.state == .waiting {
                ProgressView(loadingMessage)
                    .progressViewStyle(CircularProgressViewStyle())
                    .centeredInFrame()
            }

            let frameSize = UI.DoneIndicator.frameSize(parentSize: previewImageSize)
            if imageStore.state == .receiving, let currentStep = imageStore.currentStep {
                let stepsCompletedText = String.steps(
                    completed: currentStep + 1,
                    stepCount: imageStore.stepCount
                )
                Text(stepsCompletedText)
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

                    if let duration = imageStore.storedImages.last?.durationString {
                        Text(duration)
                            .padding(.top, UI.Spacing.extraSmall)
                    }
                }
                .transition(.symbolEffect)
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
            .lineLimit(UI.labeledContentLineLimit)
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
                title: modal.title,
                text: $imageStore.prompt
            )
        case .negativePrompt:
            PromptEditView(
                title: modal.title,
                text: $imageStore.negativePrompt
            )
        case .stepCount:
            NumberEntryView(
                title: modal.title,
                min: UI.stepCountMin,
                max: UI.stepCountMax,
                number: .fromInt($imageStore.stepCount)
            )
        case .guidanceScale:
            NumberEntryView(
                title: modal.title,
                min: UI.guidanceScaleMin,
                max: UI.guidanceScaleMax,
                isDecimalShown: true,
                number: $imageStore.guidanceScale
            )
        case .seed:
            NumberEntryView(
                title: modal.title,
                min: UI.seedMin,
                max: UI.seedMax,
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
