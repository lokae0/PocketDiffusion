//
//  ImageGenerationView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

struct ImageGenerationView: View {

    @Binding var imageStore: GeneratedImageStoring

    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""

    var body: some View {
        VStack(spacing: UI.Spacing.medium) {
            TextField("Prompt", text: $prompt)
            TextField("Negative Prompt", text: $negativePrompt)

            Button("Generate", role: nil) {
                Task {
                    Log.shared.currentThread(for: "Button Task started")
                    Timer.shared.startTimer(type: .modelLoading)

                    await imageStore.handle(
                        prompt: prompt,
                        negativePrompt: negativePrompt
                    )
                }
                Log.shared.currentThread(for: "Button closure end")
            }
        }
        .padding(UI.Spacing.large)
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGenerationView(imageStore: $previewImageStore)
}
