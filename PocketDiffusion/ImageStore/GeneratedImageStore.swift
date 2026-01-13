//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

protocol GeneratedImageStoring {

    /// Current image generation status
    var state: GenerationState { get }

    /// Updates as previews are generated. Starts with a placeholder
    var previewImage: UIImage { get set }

    /// Persisted image collection
    var storedImages: [GeneratedImage] { get }

    /// Content for an alert if an error occurs
    var errorInfo: ErrorInfo? { get set }

    /// Kicks off image generation and updates preview and result images when done
    func generateImages(with params: GenerationParameters)

    /// Cancels image generation process
    func cancelImageGeneration()
}

enum GenerationState {
    /// Startup or cancelled state
    case idle
    /// Waiting for models to load or generator to become ready
    case waiting
    /// Generation is underway and images are actively being received
    case receiving
    /// Idle state after generation completes
    case done
}

@Observable
final class GeneratedImageStore<Generator, Persistence>: GeneratedImageStoring
where Generator: Generating,
      Persistence: Persisting,
      Persistence.Model == [GeneratedImage]
{
    private(set) var state: GenerationState = .idle

    var previewImage: UIImage = .placeholder
    private(set) var storedImages: [GeneratedImage] = []
    var errorInfo: ErrorInfo?

    private let imageGenerator: Generator
    private let persistence: Persistence

    init(
        imageGenerator: Generator = ImageGenerator(),
        persistence: Persistence = FilePersistence()
    ) {
        self.imageGenerator = imageGenerator
        self.persistence = persistence

        Task {
            await tryPersistence(restore)
        }
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
            await tryPersistence(save)
        }
    }

    func cancelImageGeneration() {}

    private func save() async throws(PersistenceError) {
        try await persistence.save(model: storedImages)
    }

    private func restore() async throws(PersistenceError) {
        storedImages = try await persistence.restore()
    }

    private func tryPersistence(
        _ operation: () async throws(PersistenceError) -> Void
    ) async {
        do throws(PersistenceError) {
            try await operation()
        } catch {
            errorInfo = error.defaultInfo
        }
    }
}
