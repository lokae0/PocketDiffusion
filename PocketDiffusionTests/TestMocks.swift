//
//  TestMocks.swift
//  PocketDiffusionTests
//
//  Created by Ian Luo on 1/21/26.
//

@testable import PocketDiffusion

import UIKit

actor MockImageGenerator: Generating {

    typealias Generated = (image: UIImage, step: Int)

    /// Allows granular control over simulated generation progress during testing
    var generationContinuation: GenerationStream.Continuation?

    /// Was the `AsyncStream` returned by `generate(with:)` canceled
    var isCancelled: Bool = false

    /// The settings that `generate(:)` was called with
    var generateSettings: GenerationSettings?

    func generate(with settings: GenerationSettings) -> GenerationStream {
        AsyncThrowingStream { continuation in
            generateSettings = settings
            generationContinuation = continuation

            continuation.onTermination = { [weak self] termination in
                if case .cancelled = termination {
                    Task {
                        await self?.setCancelled()
                    }
                }
            }
        }
    }

    func setCancelled() {
        isCancelled = true
    }
}

actor MockPersistence: Persisting {

    typealias Model = [GeneratedImage]

    var persistedImages: [GeneratedImage]
    var shouldThrow: Bool

    init(
        persistedImages: [GeneratedImage] = [],
        shouldThrow: Bool = false
    ) {
        self.persistedImages = persistedImages
        self.shouldThrow = shouldThrow
    }

    func save(model: Model) throws(PersistenceError) {
        guard !shouldThrow else {
            throw .save
        }
        persistedImages = model
    }

    func restore() throws(PersistenceError) -> Model {
        guard !shouldThrow else {
            throw .restore
        }
        return persistedImages
    }
}

extension GeneratedImage {

    static var mockImageOne: GeneratedImage {
        .init(
            uiImage: UIImage(),
            settings: .init(
                prompt: "a giant cat on the moon",
                negativePrompt: "weird eyes, no hands, big feet",
                stepCount: 8,
                guidanceScale: 2.3,
                seed: UInt32.max
            ),
            duration: 50.2374235
        )
    }

    static var mockImageTwo: GeneratedImage {
        .init(
            uiImage: UIImage(),
            settings: .init(
                prompt: "A book of paint samples",
                negativePrompt: "",
                stepCount: 25,
                guidanceScale: 10,
                seed: 523523
            ),
            duration: 12.0
        )
    }
}
