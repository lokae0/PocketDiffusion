//
//  ImageGenerationView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 512.0
}

struct ImageGenerationView: View {

    @Binding var imageStore: GeneratedImageStoring

    @State private var prompt: String = .promptPlaceholder
    @State private var negativePrompt: String = .promptPlaceholder
    @State private var stepCount: Int = 25
    @State private var guidanceScale: Int = 11
    @State private var seed: UInt32 = 0
    @State private var shouldRandomize: Bool = true

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
        VStack {
           Image(uiImage: imageStore.previewImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(UI.cornerRadius)
                .frame(height: UI.imageHeight)
                .padding(
                    .horizontal,
                    UI.Spacing.medium
                )

            Form {
                labeledContent(for: .prompt, value: prompt)
                labeledContent(for: .negativePrompt, value: negativePrompt)
                labeledContent(for: .stepCount, value: String(stepCount))
                labeledContent(for: .guidanceScale, value: String(guidanceScale))
            }
            .sheet(
                item: $shownModal,
                onDismiss: {
                    withAnimation(.easeInOut) {
                        if prompt.isEmpty {
                            prompt = .promptPlaceholder
                        }
                        if negativePrompt.isEmpty {
                            negativePrompt = .promptPlaceholder
                        }
                    }
                },
                content: { modal in
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
                    default: EmptyView()
                    }
                })

            Button("Generate", role: nil) {
                imageStore.generateImages(
                    with: GenerationParameters(
                        prompt: prompt == .promptPlaceholder ? "" : prompt,
                        negativePrompt: negativePrompt == .promptPlaceholder ? "" : prompt,
                        stepCount: stepCount,
                        guidanceScale: guidanceScale,
                        seed: seed,
                        shouldRandomize: shouldRandomize
                    )
                )
            }
            .controlSize(.large)
            .buttonStyle(.glass)
            .padding(
                [.bottom],
                UI.Spacing.large
            )
        }
    }

    @ViewBuilder
    private func labeledContent(for modal: Modal, value: String) -> some View {
        LabeledContent(modal.title, value: value)
            .lineLimit(1)
            .contentShape(Rectangle())
            .onTapGesture {
                shownModal = modal
            }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGenerationView(imageStore: $previewImageStore)
}
