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

    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""
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
        VStack(spacing: UI.Spacing.small) {
           Image(uiImage: imageStore.currentGeneration.uiImage)
                .resizable()
                .scaledToFit()
                .contentTransition(.opacity)
                .cornerRadius(UI.cornerRadius)
                .frame(height: UI.imageHeight)

            Form {
                LabeledContent(Modal.prompt.title, value: prompt)
                    .onTapGesture {
                        shownModal = .prompt
                    }
                LabeledContent(Modal.negativePrompt.title, value: negativePrompt)
                    .onTapGesture {
                        shownModal = .negativePrompt
                    }
            }
            .sheet(item: $shownModal) { modal in
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
            }


            Button("Generate", role: nil) {
                Timer.shared.startTimer(type: .modelLoading)
                imageStore.generateImages(
                    with: GenerationParameters(
                        prompt: prompt,
                        negativePrompt: negativePrompt,
                        stepCount: stepCount,
                        guidanceScale: guidanceScale,
                        seed: seed,
                        shouldRandomize: shouldRandomize
                    )
                )
            }
        }
        .padding(UI.Spacing.large)
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGenerationView(imageStore: $previewImageStore)
}
