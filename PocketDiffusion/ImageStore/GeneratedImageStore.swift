//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit
import SwiftUI

protocol GeneratedImageStoring {

    /// Current image generation status
    var state: GenerationState { get }

    /// Updates as previews are generated. Starts with a placeholder
    var previewImage: UIImage { get set }

    /// Current progress step while generating images
    var currentStep: Int? { get }

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
    var currentStep: Int?

    private(set) var storedImages: [GeneratedImage] = []
    var errorInfo: ErrorInfo?

    private let imageGenerator: Generator
    private let persistence: Persistence

    private var generationTask: Task<Void, Never>?

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

        generationTask = Task {
            do {
                for await generated in try await imageGenerator.generate(with: params) {
                    guard let result = generated as? (image: UIImage, step: Int) else {
                        Log.shared.info("Unexpected generation type!!")
                        continue
                    }
                    Log.shared.currentThread(
                        "Receiving preview images",
                        isEnabled: false
                    )
                    state = .receiving
                    previewImage = result.image
                    currentStep = result.step
                }
            } catch {
                errorInfo = ErrorInfo(
                    title: "Image generation failed",
                    message: "Please try again"
                )
                Log.shared.info("Image generation error: \(error.localizedDescription)")
            }

            guard !Task.isCancelled else {
                Timer.shared.stopTimer(type: .imageGeneration, shouldLog: false)
                return
            }
            let duration = Timer.shared.stopTimer(type: .imageGeneration)
            state = .done
            currentStep = nil

            // Last preview image is the final result
            storedImages.append(
                GeneratedImage(
                    uiImage: previewImage,
                    params: params,
                    duration: duration
                )
            )
            await tryPersistence(save)
        }
    }

    func cancelImageGeneration() {
        generationTask?.cancel()
        previewImage = .placeholder
        currentStep = nil
        state = .idle

        Log.shared.info("Cancel requested...")

    }

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
