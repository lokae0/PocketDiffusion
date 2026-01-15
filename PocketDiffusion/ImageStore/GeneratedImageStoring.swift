//
//  GeneratedImageStoring.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/14/26.
//

import UIKit

protocol GeneratedImageStoring {

    /// Current image generation status
    var state: GenerationState { get }

    /// Descriptive prompt for the image generator
    var prompt: String { get set }

    /// Tells generator what it should try not to include
    var negativePrompt: String { get set }

    /// How many iterative processes the generator should run
    var stepCount: Int { get set }

    /// How much the generator should try to adhere to the prompt.
    /// A lower value may allow more "creative" results
    var guidanceScale: Double { get set }

    /// If all other values are constant, using the same seed will
    /// always produce the same result
    var seed: Int { get set }

    /// Should the seed be randomized
    var isSeedRandom: Bool { get set }

    /// Updates as previews are generated. Starts with a placeholder
    var previewImage: UIImage { get }

    /// Current progress step while generating images
    var currentStep: Int? { get }

    /// Persisted collection of completed generations
    var storedImages: [GeneratedImage] { get }

    /// Content for an alert if an error occurs
    var errorInfo: ErrorInfo? { get set }

    /// Kicks off image generation using `currentParams`
    /// and updates preview and result images when done
    func generateImages()

    /// Cancels image generation process
    func cancelImageGeneration()

    /// Allows the preview image to be set externally
    /// - Parameters:
    ///   - previewImage: The new image to display. Nil will show the placeholder
    ///   - shouldResetState: Sets the state back to `idle` when true
    func update(previewImage: UIImage?, shouldResetState: Bool)
}
