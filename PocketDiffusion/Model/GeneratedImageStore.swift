//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

protocol GeneratedImageStoring {
    var generatedImages: [GeneratedImage] { get }
    func handle(prompt: String, negativePrompt: String) async
}

@Observable
final class GeneratedImageStore: GeneratedImageStoring {

    private(set) var generatedImages: [GeneratedImage] = []
    private let imageGenerator: any Generating

    init(imageGenerator: any Generating = ImageGenerator()) {
        self.imageGenerator = imageGenerator
    }

    func handle(prompt: String, negativePrompt: String) async {
        guard let uiImage = await imageGenerator.generate(
            prompt: prompt,
            negativePrompt: negativePrompt
        ) as? UIImage else {
            return
        }
        Timer.shared.stopTimer(type: .imageGeneration)

        generatedImages.append(
            .init(uiImage: uiImage)
        )
    }
}
