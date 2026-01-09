//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

public protocol GeneratedImageStoring {

    /// Current image generation status
    var state: GenerationState { get }

    /// Updates as previews are generated. Starts with a placeholder
    var previewImage: UIImage { get set }

    /// Persisted image collection
    var storedImages: [GeneratedImage] { get }

    /// Kicks off image generation and updates preview and result images when done
    func generateImages(with params: GenerationParameters)
}

public enum GenerationState {
    /// Startup state
    case initial
    /// Waiting for models to load or generator to become ready
    case waiting
    /// Generation is underway and images are actively being received
    case receiving
    /// Idle state after generation completes
    case done
}

@Observable
final class GeneratedImageStore<Generator: Generating>: GeneratedImageStoring {

    private(set) var state: GenerationState = .initial

    var previewImage: UIImage = .placeholder
    private(set) var storedImages: [GeneratedImage] = []

    private let imageGenerator: Generator

    init(imageGenerator: Generator = ImageGenerator()) {
        self.imageGenerator = imageGenerator
    }

    func generateImages(with params: GenerationParameters) {
        state = .waiting
        previewImage = .placeholder
        Timer.shared.startTimer(type: .awaitingPipeline)

        Task {
            for await generated in await imageGenerator.generate(with: params) {
                guard let uiImage = generated as? UIImage else {
                    Log.shared.info("Unexpected type for generated image!!")
                    continue
                }
                Log.shared.currentThread(
                    for: "Receiving preview images",
                    isEnabled: false
                )
                state = .receiving
                previewImage = uiImage
            }

            Timer.shared.stopTimer(type: .imageGeneration)
            state = .done

            // Last preview image is the final result
            storedImages.append(
                GeneratedImage(
                    uiImage: previewImage,
                    params: params
                )
            )
        }
    }
}
