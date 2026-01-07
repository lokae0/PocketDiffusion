//
//  ContentView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 11/25/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {

    private enum UI {
        static let cornerRadius: CGFloat = 16.0

        enum Spacing {
            static let medium: CGFloat = 16.0
            static let large: CGFloat = 32.0
        }
    }

    @State private var imageStore: GeneratedImageStore = .init()
    @State private var prompt: String = ""
    @State private var negativePrompt: String = ""

    var body: some View {
        let cornerRadius = UI.cornerRadius

        VStack(spacing: UI.Spacing.medium) {
            TextField("Prompt", text: $prompt)
            TextField("Negative Prompt", text: $negativePrompt)

            if imageStore.generatedImages.isEmpty == false {
                List {
                    ForEach(imageStore.generatedImages) { generatedImage in
                        Image(uiImage: generatedImage.uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(cornerRadius)
                        
//                        Text("Name: \(tree.name)")
//                        Text("Confidence: \(tree.confidence)")
                    }
                }
            }

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
    ContentView()
}
