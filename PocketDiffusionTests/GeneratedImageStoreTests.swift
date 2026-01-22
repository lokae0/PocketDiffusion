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

    // MARK: - Functionality tests

    @Test func initialization() async {
        let expectedImages = [GeneratedImage.mockImageTwo]
        mockPersistence = MockPersistence(persistedImages: expectedImages)

        recreateImageStore()

        #expect(imageStore.state == .idle)
        #expect(imageStore.currentStep == nil)
        #expect(imageStore.errorInfo == nil)

        // Ensure persistence `restore` was called
        await imageStore.persistenceTask?.value
        #expect(imageStore.storedImages == expectedImages)
    }

    @Test func generateImageSetup() async throws {
        let expectedSettings = GeneratedImage.mockImageOne.settings

        imageStore.prompt = expectedSettings.prompt
        imageStore.negativePrompt = expectedSettings.negativePrompt
        imageStore.stepCount = expectedSettings.stepCount
        imageStore.guidanceScale = expectedSettings.guidanceScale
        imageStore.seed = Int(expectedSettings.seed)
        imageStore.isSeedRandom = false

        imageStore.update(previewImage: UIImage(), shouldResetState: false)

        imageStore.generateImages()
        #expect(imageStore.state == .waiting)
        #expect(imageStore.previewImage == nil)
        #expect(imageStore.generationTask != nil)

        await imageStore.generationTask?.value

        let generateSettings = try #require(await mockImageGenerator.generateSettings)
        #expect(generateSettings == expectedSettings)
    }

    @Test func consumeImages() async {
        let testImage = UIImage()
        let results = [(image: testImage, step: 1)]
        mockImageGenerator = MockImageGenerator(mockResults: results)

        // Simulates generation in progress
        await imageStore.consumeGeneratedImages(
            mockImageGenerator.generate(with: GeneratedImage.mockImageOne.settings)
        )
        #expect(imageStore.previewImage == testImage)
        #expect(imageStore.currentStep == 1)
        #expect(imageStore.state == .receiving)
    }

    @Test func finishGeneration() async throws {
        let expectedImage = UIImage()
        let results = [(image: expectedImage, step: 1)]
        mockImageGenerator = MockImageGenerator(mockResults: results)
        recreateImageStore()

        imageStore.generateImages()
        await imageStore.generationTask?.value

        #expect(imageStore.state == .done)
        #expect(imageStore.currentStep == nil)

        let expectedSettings = await mockImageGenerator.generateSettings

        let finalImage = try #require(imageStore.storedImages.first)
        #expect(finalImage.uiImage == expectedImage)
        #expect(finalImage.settings == expectedSettings)

        #expect(await mockPersistence.persistedImages == [finalImage])
    }

    @Test func cancelGenerationTask() async throws {
        imageStore.generateImages()

        imageStore.cancelImageGeneration()

        let generationTask = try #require(imageStore.generationTask)
        #expect(generationTask.isCancelled)

        // Ensure task cancellation propagates to the underlying image generator
        await generationTask.value
        #expect(await mockImageGenerator.isCancelled)
    }

    @Test func cancelGenerationState() async {
        let testImage = UIImage()
        let results = [(image: testImage, step: 1)]
        mockImageGenerator = MockImageGenerator(mockResults: results)

        // Simulates generation in progress
        await imageStore.consumeGeneratedImages(
            mockImageGenerator.generate(with: GeneratedImage.mockImageOne.settings)
        )

        imageStore.cancelImageGeneration()

        #expect(imageStore.previewImage == nil)
        #expect(imageStore.currentStep == nil)
        #expect(imageStore.state == .idle)
    }

    // Note: trying this out, but this particular example of a Parameterized Test is
    // harder to understand and less convenient than simply repeating the test logic
    @Test(arguments: zip([
        (image: UIImage(), shouldResetState: true),
        (image: nil, shouldResetState: false),
    ], [
        (isImageExpected: true, expectedState: GenerationState.idle),
        (isImageExpected: false, expectedState: GenerationState.waiting),
    ]))
    func updatePreview(
        inputs: (image: UIImage?, shouldResetState: Bool),
        expectations: (isImageExpected: Bool, expectedState: GenerationState)
    ) {
        // Force waiting state
        imageStore.generateImages()

        imageStore.update(
            previewImage: inputs.image,
            shouldResetState: inputs.shouldResetState
        )
        let expectedImage = expectations.isImageExpected ? inputs.image : nil
        #expect(imageStore.previewImage == expectedImage)
        #expect(imageStore.state == expectations.expectedState)
    }

    @Test func deleteImages() async {
        // Seed image data
        let startImages: [GeneratedImage] = [.mockImageOne, .mockImageTwo]
        mockPersistence = MockPersistence(persistedImages: startImages)

        // Load images
        recreateImageStore()
        await imageStore.persistenceTask?.value

        let expectedImages = Array(startImages.dropFirst())

        imageStore.deleteImages(at: IndexSet(integer: 0))
        #expect(imageStore.storedImages == expectedImages)

        // Ensure persistence `save` was called
        await imageStore.persistenceTask?.value
        #expect(await mockPersistence.persistedImages == expectedImages)
    }

    @Test func moveImages() async {
        // Seed image data
        let startImages: [GeneratedImage] = [.mockImageOne, .mockImageTwo]
        mockPersistence = MockPersistence(persistedImages: startImages)

        // Load images
        recreateImageStore()
        await imageStore.persistenceTask?.value

        imageStore.moveImages(from: IndexSet(integer: 0), to: 2)
        #expect(imageStore.storedImages == startImages.reversed())

        // Ensure persistence `save` was called
        await imageStore.persistenceTask?.value
        #expect(await mockPersistence.persistedImages == startImages.reversed())
    }

    // MARK: - Error tests

    @Test func persistenceError() async {
        mockPersistence = MockPersistence(shouldThrow: true)

        // Calls restore
        recreateImageStore()
        await imageStore.persistenceTask?.value

        #expect(imageStore.errorInfo == PersistenceError.restore.defaultInfo)
    }

    @Test func imageGenerationError() async {
        mockImageGenerator = MockImageGenerator(shouldError: true)
        recreateImageStore()

        imageStore.generateImages()
        await imageStore.generationTask?.value

        #expect(imageStore.errorInfo != nil)
        #expect(imageStore.generationTask?.isCancelled == true)
    }

    // MARK: - User Defaults tests

    @Test func prompt() async {
        let setPrompt = "A bored tigershark"
        await MainActor.run {
            imageStore.prompt = setPrompt
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.prompt) as? String == setPrompt)

        let getPrompt = "An excited porpoise"
        userDefaults.set(getPrompt, forKey: .UserDefaultsKeys.prompt)
        #expect(imageStore.prompt == getPrompt)
    }

    @Test func negativePrompt() async {
        let setNegativePrompt = "Earth, wind"
        await MainActor.run {
            imageStore.negativePrompt = setNegativePrompt
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.negativePrompt) as? String == setNegativePrompt)

        let getNegativePrompt = "Water, fire"
        userDefaults.set(getNegativePrompt, forKey: .UserDefaultsKeys.negativePrompt)
        #expect(imageStore.negativePrompt == getNegativePrompt)
    }

    @Test func stepCount() async {
        let setStepCount = 14
        await MainActor.run {
            imageStore.stepCount = setStepCount
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.stepCount) as? Int == setStepCount)

        let getStepCount = 7
        userDefaults.set(getStepCount, forKey: .UserDefaultsKeys.stepCount)
        #expect(imageStore.stepCount == getStepCount)
    }

    @Test func guidanceScale() async {
        let setScale = 5.7
        await MainActor.run {
            imageStore.guidanceScale = setScale
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.guidanceScale) as? Double == setScale)

        let getScale = 12.2
        userDefaults.set(getScale, forKey: .UserDefaultsKeys.guidanceScale)
        #expect(imageStore.guidanceScale == getScale)
    }

    @Test func seed() async {
        let setSeed = 123456
        await MainActor.run {
            imageStore.seed = setSeed
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.seed) as? Int == setSeed)

        let getSeed = 78910
        userDefaults.set(getSeed, forKey: .UserDefaultsKeys.seed)
        #expect(imageStore.seed == getSeed)
    }

    @Test func isSeedRandom() async {
        await MainActor.run {
            imageStore.isSeedRandom = false
        }
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.isSeedRandom) as? Bool == false)

        userDefaults.set(true, forKey: .UserDefaultsKeys.isSeedRandom)
        #expect(imageStore.isSeedRandom == true)
    }
}

private extension GeneratedImageStoreTests {

    func recreateImageStore() {
        imageStore = GeneratedImageStore(
            imageGenerator: mockImageGenerator,
            persistence: mockPersistence,
            userDefaults: userDefaults
        )
    }
}
