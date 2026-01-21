//
//  GeneratedImageStoreTests.swift
//  PocketDiffusionTests
//
//  Created by Ian Luo on 11/25/25.
//

@testable import PocketDiffusion

import Testing
import UIKit

@MainActor
class GeneratedImageStoreTests {

    var mockImageGenerator: MockImageGenerator
    var mockPersistence: MockPersistence
    var userDefaults: UserDefaults

    var imageStore: GeneratedImageStore<MockImageGenerator, MockPersistence>

    init() {
        self.mockImageGenerator = MockImageGenerator()
        self.mockPersistence = MockPersistence()
        self.userDefaults = UserDefaults(suiteName: #file)!

        self.imageStore = GeneratedImageStore(
            imageGenerator: mockImageGenerator,
            persistence: mockPersistence,
            userDefaults: userDefaults
        )
    }

    deinit {
        userDefaults.removePersistentDomain(forName: #file)
    }

    @Test func initialization() async {
        let expectedImages = [GeneratedImage.mockImageTwo]
        mockPersistence = MockPersistence(persistedImages: expectedImages)

        imageStore = GeneratedImageStore(
            imageGenerator: mockImageGenerator,
            persistence: mockPersistence,
            userDefaults: userDefaults
        )

        #expect(imageStore.state == .idle)
        #expect(imageStore.currentStep == nil)
        #expect(imageStore.errorInfo == nil)

        // Ensure MockPersistence `restore` was called
        await imageStore.persistenceTask?.value
        #expect(imageStore.storedImages == expectedImages)
    }

    @Test func generateImages() {


        imageStore.generateImages()
        #expect(imageStore.state == .waiting)
    }

    @Test func moveImages() {

    }

}

actor MockImageGenerator: Generating {

    typealias Generated = (image: UIImage, step: Int)

    /// Allows granular control over simulated generation progress during testing
    var generationContinuation: AsyncStream<Generated>.Continuation?

    /// Was the `AsyncStream` returned by `generate(with:)` canceled
    var isCancelled: Bool = false

    func generate(with settings: GenerationSettings) throws -> AsyncStream<Generated> {
        AsyncStream { continuation in
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
