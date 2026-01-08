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

    var body: some View {
        VStack(spacing: UI.Spacing.medium) {
           Image(uiImage: imageStore.currentGeneration.uiImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(UI.cornerRadius)
                .frame(height: UI.imageHeight)

            TextField("Prompt", text: $prompt)
            TextField("Negative Prompt", text: $negativePrompt)

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
