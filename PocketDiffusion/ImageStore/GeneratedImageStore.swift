//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

public protocol GeneratedImageStoring {

    /// Updates as previews are generated. Starts with a placeholder
    var previewImage: UIImage { get set }

    /// Persisted image collection
    var storedImages: [GeneratedImage] { get }

    /// Kicks off image generation and updates preview and result images when done
    func generateImages(with params: GenerationParameters)
}

@Observable
final class GeneratedImageStore<Generator: Generating>: GeneratedImageStoring {

    var previewImage: UIImage = .image(color: .gray)
    private(set) var storedImages: [GeneratedImage] = []

    private let imageGenerator: Generator

    init(imageGenerator: Generator = ImageGenerator()) {
        self.imageGenerator = imageGenerator
    }

    func generateImages(with params: GenerationParameters) {
        Task {
            for await generated in await imageGenerator.generate(with: params) {
                guard let uiImage = generated as? UIImage else {
                    Log.shared.info("Unexpected type for generated image!!")
                    continue
                }
                Log.shared.currentThread(
                    for: "Setting currentGeneration",
                    isEnabled: false
                )
                previewImage = uiImage
            }
            // Last preview image is the final result
            storedImages.append(
                GeneratedImage(
                    uiImage: previewImage,
                    params: params
                )
            )
            Timer.shared.stopTimer(type: .imageGeneration)
        }
    }
}
