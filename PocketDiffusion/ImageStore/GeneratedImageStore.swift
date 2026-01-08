//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

protocol GeneratedImageStoring {

    var currentGeneration: GeneratedImage? { get set }
    var storedImages: [GeneratedImage] { get }

    func handle(
        prompt: String,
        negativePrompt: String
    )
}

@Observable
final class GeneratedImageStore<Generator: Generating>: GeneratedImageStoring {

    var currentGeneration: GeneratedImage?
    private(set) var storedImages: [GeneratedImage] = []
    private let imageGenerator: Generator

    init(imageGenerator: Generator = ImageGenerator()) {
        self.imageGenerator = imageGenerator
    }

    func handle(
        prompt: String,
        negativePrompt: String
    ) {
        Task {
            for await generated in await imageGenerator.generate(
                prompt: prompt,
                negativePrompt: negativePrompt
            ) {
                guard let uiImage = generated as? UIImage else {
                    Log.shared.info("Unexpected type for generated image!!")
                    continue
                }
                Log.shared.currentThread(
                    for: "Setting currentGeneration",
                    isEnabled: false
                )
                currentGeneration = GeneratedImage(uiImage: uiImage)
            }

            if let gen = currentGeneration {
                storedImages.append(gen)
            }
            Timer.shared.stopTimer(type: .imageGeneration)
        }
    }
}
