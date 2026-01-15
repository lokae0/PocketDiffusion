//
//  ImageDetailView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/14/26.
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
}

struct ImageDetailView: View {

    var image: GeneratedImage

    private var params: GenerationParameters {
        image.params
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: UI.Spacing.large) {
                Image(uiImage: image.uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(UI.cornerRadius)
                    .frame(maxWidth: UI.imageHeight, maxHeight: UI.imageHeight)
                    .centeredInFrame()
                
                promptLabels(title: "Prompt", content: params.prompt)
                
                promptLabels(title: "Negative prompt", content: params.negativePrompt)

                numberLabels
            }
            .padding(UI.Spacing.medium)
        }
        .scrollIndicators(.hidden)
    }
}

private extension ImageDetailView {

    @ViewBuilder
    private func promptLabels(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            Text(title)
                .font(.system(.headline))
            Text(content)
        }
    }

    @ViewBuilder
    private var numberLabels: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            Text("Steps: \(params.stepCount)")
                .fontWeight(.medium)
            let guidanceFormat = String(format: "%.1f", arguments: [params.guidanceScale])
            Text("Guidance scale: \(guidanceFormat)")
                .fontWeight(.medium)
            Text("Seed: \(params.seed)")
                .fontWeight(.medium)
            Text("Generated in: \(image.durationString)")
                .fontWeight(.medium)
        }
    }
}

#Preview {
    @Previewable var generatedImage: GeneratedImage = .init(
        uiImage: .image(color: .darkGray),
        params: .init(
            prompt: String.samplePrompt,
            negativePrompt: String.sampleNegativePrompt,
            stepCount: 50,
            guidanceScale: 15.0,
            seed: UInt32.max
        ),
        duration: 5.897
    )
    ImageDetailView(image: generatedImage)
}
