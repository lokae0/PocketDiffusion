//
//  TestMocks.swift
//  PocketDiffusionTests
//
//  Created by Ian Luo on 1/21/26.
//

@testable import PocketDiffusion

import UIKit

struct MockError: Error {}

actor MockImageGenerator: Generating {

    typealias Generated = (image: UIImage, step: Int)

    /// Values to be emitted upon calling `generate`
    var mockResults: [Generated]

    /// Will simulate an error when true
    var shouldError: Bool

    /// Was the `AsyncStream` returned by `generate(with:)` canceled
    private(set) var isCancelled: Bool = false

    /// The settings that `generate(:)` was called with
    private(set) var generateSettings: GenerationSettings?

    /// Creates a mock image generator for tests.
    ///
    /// - Parameters:
    ///   - mockResults: The sequence of `(image, step)` tuples that will be emitted
    ///     in order when `generate(with:)` is called. Defaults to an empty array,
    ///     which yields nothing and immediately finishes.
    ///   - shouldError: When `true`, the mock can be configured by tests to simulate
    ///     an error path. Defaults to `false`.
    init(
        mockResults: [Generated] = [],
        shouldError: Bool = false
    ) {
        self.mockResults = mockResults
        self.shouldError = shouldError
    }

    func generate(with settings: GenerationSettings) -> GenerationStream {
        AsyncThrowingStream { continuation in
            generateSettings = settings

            guard !shouldError else {
                continuation.finish(throwing: MockError())
                return
            }
            mockResults.forEach {
                continuation.yield($0)
            }
            continuation.finish()

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
