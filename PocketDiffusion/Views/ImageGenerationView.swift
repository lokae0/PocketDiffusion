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

    var body: some View {
        VStack(spacing: UI.Spacing.medium) {
            if let image = imageStore.currentGeneration?.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(UI.cornerRadius)
                    .frame(height: UI.imageHeight)
            }

            TextField("Prompt", text: $prompt)
            TextField("Negative Prompt", text: $negativePrompt)

            Button("Generate", role: nil) {
                Timer.shared.startTimer(type: .modelLoading)

                imageStore.handle(
                    prompt: prompt,
                    negativePrompt: negativePrompt
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
