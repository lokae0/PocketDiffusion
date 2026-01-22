//
//  GeneratedImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit
import SwiftUI

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

private extension String {
    static let generationErrorTitle = String(localized: "Image generation failed")
    static let generationErrorMessage = String(localized: "Please try again")
}

@Observable
final class GeneratedImageStore<Generator, Persistence>: GeneratedImageStoring
where Generator: Generating,
      Persistence: Persisting,
      Persistence.Model == [GeneratedImage]
{
    private(set) var state: GenerationState = .idle

    var prompt: String {
        get {
            access(keyPath: \.prompt)
            return userDefaults.string(forKey: .UserDefaultsKeys.prompt) ?? ""
        }
        set {
            withMutation(keyPath: \.prompt) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.prompt)
            }
        }
    }
    var negativePrompt: String {
        get {
            access(keyPath: \.negativePrompt)
            return userDefaults.string(forKey: .UserDefaultsKeys.negativePrompt) ?? ""
        }
        set {
            withMutation(keyPath: \.negativePrompt) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.negativePrompt)
            }
        }
    }
    var stepCount: Int {
        get {
            access(keyPath: \.stepCount)
            return userDefaults.object(forKey: .UserDefaultsKeys.stepCount) as? Int ?? 25
        }
        set {
            withMutation(keyPath: \.stepCount) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.stepCount)
            }
        }
    }
    var guidanceScale: Double {
        get {
            access(keyPath: \.guidanceScale)
            return userDefaults.object(forKey: .UserDefaultsKeys.guidanceScale) as? Double ?? 11
        }
        set {
            withMutation(keyPath: \.guidanceScale) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.guidanceScale)
            }
        }
    }
    var seed: Int {
        get {
            access(keyPath: \.seed)
            return userDefaults.object(forKey: .UserDefaultsKeys.seed) as? Int ?? 0
        }
        set {
            withMutation(keyPath: \.guidanceScale) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.seed)
            }
        }
    }
    var isSeedRandom: Bool {
        get {
            access(keyPath: \.isSeedRandom)
            return userDefaults.object(forKey: .UserDefaultsKeys.isSeedRandom) as? Bool ?? true
        }
        set {
            withMutation(keyPath: \.isSeedRandom) {
                userDefaults.setValue(newValue, forKey: .UserDefaultsKeys.isSeedRandom)
            }
        }
    }

    private(set) var previewImage: UIImage?
    private(set) var currentStep: Int?

    private(set) var storedImages: [GeneratedImage] = []
    var errorInfo: ErrorInfo?

    private let imageGenerator: Generator
    private let persistence: Persistence
    private let userDefaults: UserDefaults

    private(set) var generationTask: Task<Void, Never>?
    private(set) var persistenceTask: Task<Void, Never>?

    init(
        imageGenerator: Generator = ImageGenerator(),
        persistence: Persistence = FilePersistence(),
        userDefaults: UserDefaults = .standard
    ) {
        self.imageGenerator = imageGenerator
        self.persistence = persistence
        self.userDefaults = userDefaults

        persistenceTask = Task {
            await tryPersistence(restore)
        }
    }

    func generateImages() {
        state = .waiting
        previewImage = nil
        Timer.shared.startTimer(type: .awaitingPipeline)

        let settings = GenerationSettings(
            prompt: prompt,
            negativePrompt: negativePrompt,
            stepCount: stepCount,
            guidanceScale: guidanceScale,
            seed: isSeedRandom ? UInt32.random(in: 0..<UInt32.max) : UInt32(seed),
        )
        generationTask = Task {
            await consumeGeneratedImages(
                imageGenerator.generate(with: settings)
            )

            guard !Task.isCancelled else {
                Timer.shared.stopTimer(type: .imageGeneration, shouldLog: false)
                return
            }
            await finishGeneration(with: settings)
        }
    }

    func cancelImageGeneration() {
        generationTask?.cancel()
        previewImage = nil
        currentStep = nil
        state = .idle

        Log.shared.info("Cancel requested...")
    }

    func update(previewImage: UIImage?, shouldResetState: Bool) {
        if let previewImage {
            self.previewImage = previewImage
        } else {
            self.previewImage = nil
        }
        if shouldResetState {
            state = .idle
        }
    }

    func deleteImages(at offsets: IndexSet) {
        storedImages.remove(atOffsets: offsets)
        persistenceTask = Task {
            await tryPersistence(save)
        }
    }

    func moveImages(from source: IndexSet, to destination: Int) {
        storedImages.move(fromOffsets: source, toOffset: destination)
        persistenceTask = Task {
            await tryPersistence(save)
        }
    }
}

// MARK: - Internal and private

extension GeneratedImageStore {

    // Internal helper to support unit testing
    func consumeGeneratedImages<Generated>(
        _ stream: AsyncThrowingStream<Generated, Error>
    ) async {
        do {
            for try await generated in stream {
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
            cancelImageGeneration()

            errorInfo = ErrorInfo(
                title: String.generationErrorTitle,
                message: String.generationErrorMessage
            )
            Log.shared.info("Image generation error: \(error.localizedDescription)")
        }
    }

    private func finishGeneration(with settings: GenerationSettings) async {
        let duration = Timer.shared.stopTimer(type: .imageGeneration)
        state = .done
        currentStep = nil

        // Last preview image is the final result
        storedImages.append(
            GeneratedImage(
                uiImage: previewImage ?? .placeholder,
                settings: settings,
                duration: duration
            )
        )
        await tryPersistence(save)
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
