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

        // Ensure persistence `restore` was called
        await imageStore.persistenceTask?.value
        #expect(imageStore.storedImages == expectedImages)
    }

    @Test func generateImages() async throws {
        let expectedSettings = GeneratedImage.mockImageOne.settings

        imageStore.prompt = expectedSettings.prompt
        imageStore.negativePrompt = expectedSettings.negativePrompt
        imageStore.stepCount = expectedSettings.stepCount
        imageStore.guidanceScale = expectedSettings.guidanceScale
        imageStore.seed = Int(expectedSettings.seed)
        imageStore.isSeedRandom = false

        imageStore.generateImages()
        #expect(imageStore.state == .waiting)

        let expectedImage = UIImage()
        let expectedStep = 1

        // Simulate generation streaming output
        await mockImageGenerator.generationContinuation?.yield(
            (image: expectedImage, step: expectedStep)
        )

        let generateSettings = try #require(await mockImageGenerator.generateSettings)
        #expect(generateSettings == expectedSettings)

//        #expect(imageStore.state == .receiving)
//        #expect(imageStore.previewImage == expectedImage)
//        #expect(imageStore.currentStep == expectedStep)

        // End streaming
        await mockImageGenerator.generationContinuation?.finish()
        await imageStore.generationTask?.value

        #expect(imageStore.state == .done)
        #expect(imageStore.currentStep == nil)

        let finalImage = try #require(imageStore.storedImages.first)
//        #expect(finalImage.uiImage == expectedImage)
        #expect(finalImage.settings == expectedSettings)

        #expect(await mockPersistence.persistedImages == [finalImage])
    }

    @Test func cancelGeneration() async throws {
        imageStore.generateImages()
        imageStore.cancelImageGeneration()

        // Add one round of iteration to test things get reset correctly

        let generationTask = try #require(imageStore.generationTask)
        #expect(generationTask.isCancelled)
        #expect(imageStore.currentStep == nil)
        #expect(imageStore.state == .idle)
    }

    // Note: trying this out, but this particular example of a Parameterized Test is
    // harder to understand and less convenient than simply repeating the test logic
    @Test(arguments: zip([
        (image: UIImage(), shouldResetState: true),
        (image: nil, shouldResetState: false),
    ], [
        (isImagePresent: true, state: GenerationState.idle),
        (isImagePresent: false, state: GenerationState.waiting),
    ]))
    func updatePreview(
        inputs: (image: UIImage?, shouldResetState: Bool),
        expectations: (isImagePresent: Bool, state: GenerationState)
    ) {
        // Force waiting state
        imageStore.generateImages()

        imageStore.update(
            previewImage: inputs.image,
            shouldResetState: inputs.shouldResetState
        )
        let expectedImage = expectations.isImagePresent ? inputs.image : nil
        #expect(imageStore.previewImage == expectedImage)
        #expect(imageStore.state == expectations.state)
    }

    @Test func deleteImages() async {
        // Seed image data
        let startImages: [GeneratedImage] = [.mockImageOne, .mockImageTwo]
        mockPersistence = MockPersistence(persistedImages: startImages)

        imageStore = GeneratedImageStore(
            imageGenerator: mockImageGenerator,
            persistence: mockPersistence,
            userDefaults: userDefaults
        )
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

        imageStore = GeneratedImageStore(
            imageGenerator: mockImageGenerator,
            persistence: mockPersistence,
            userDefaults: userDefaults
        )
        await imageStore.persistenceTask?.value

        imageStore.moveImages(from: IndexSet(integer: 0), to: 2)
        #expect(imageStore.storedImages == startImages.reversed())

        // Ensure persistence `save` was called
        await imageStore.persistenceTask?.value
        #expect(await mockPersistence.persistedImages == startImages.reversed())
    }

    // MARK: - User Defaults tests

    @Test func prompt() {
        let setPrompt = "A bored tigershark"
        imageStore.prompt = setPrompt
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.prompt) as? String == setPrompt)

        let getPrompt = "An excited porpoise"
        userDefaults.set(getPrompt, forKey: .UserDefaultsKeys.prompt)
        #expect(imageStore.prompt == getPrompt)
    }

    @Test func negativePrompt() {
        let setNegativePrompt = "Earth, wind"
        imageStore.negativePrompt = setNegativePrompt
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.negativePrompt) as? String == setNegativePrompt)

        let getNegativePrompt = "Water, fire"
        userDefaults.set(getNegativePrompt, forKey: .UserDefaultsKeys.negativePrompt)
        #expect(imageStore.negativePrompt == getNegativePrompt)
    }

    @Test func stepCount() {
        let setStepCount = 14
        imageStore.stepCount = setStepCount
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.stepCount) as? Int == setStepCount)

        let getStepCount = 7
        userDefaults.set(getStepCount, forKey: .UserDefaultsKeys.stepCount)
        #expect(imageStore.stepCount == getStepCount)
    }

    @Test func guidanceScale() {
        let setScale = 5.7
        imageStore.guidanceScale = setScale
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.guidanceScale) as? Double == setScale)

        let getScale = 12.2
        userDefaults.set(getScale, forKey: .UserDefaultsKeys.guidanceScale)
        #expect(imageStore.guidanceScale == getScale)
    }

    @Test func seed() {
        let setSeed = 123456
        imageStore.seed = setSeed
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.seed) as? Int == setSeed)

        let getSeed = 78910
        userDefaults.set(getSeed, forKey: .UserDefaultsKeys.seed)
        #expect(imageStore.seed == getSeed)
    }

    @Test func isSeedRandom() {
        imageStore.isSeedRandom = true
        #expect(userDefaults.object(forKey: .UserDefaultsKeys.isSeedRandom) as? Bool == true)
        userDefaults.set(false, forKey: .UserDefaultsKeys.isSeedRandom)
        #expect(imageStore.isSeedRandom == false)
    }
}
