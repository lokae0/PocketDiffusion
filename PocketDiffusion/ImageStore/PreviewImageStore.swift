//
//  PreviewImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import UIKit

@Observable
final class PreviewImageStore: GeneratedImageStoring {

    var state: GenerationState

    var prompt: String = ""
    var negativePrompt: String = ""
    var stepCount: Int = 25
    var guidanceScale: Double = 11
    var seed: Int = 0
    var isSeedRandom: Bool = true

    var previewImage: UIImage = .placeholder

    var currentStep: Int?

    var storedImages: [GeneratedImage]

    var errorInfo: ErrorInfo?

    init(
        state: GenerationState = .idle,
        currentStep: Int? = 3,
        storedImages: [GeneratedImage] = [
            .init(
                uiImage: .image(color: .darkGray),
                settings: .init(
                    prompt: String.samplePrompt,
                    negativePrompt: "",
                    stepCount: 25,
                    guidanceScale: 11.0,
                    seed: 0
                ),
                duration: 5.897
            ),
            .init(
                uiImage: .image(color: .lightGray),
                settings: .init(
                    prompt: "a giant cat on the moon",
                    negativePrompt: "weird eyes, no hands, big feet",
                    stepCount: 8,
                    guidanceScale: 2.3,
                    seed: UInt32.max
                ),
                duration: 50.2374235
            ),
            .init(
                uiImage: .image(color: .gray),
                settings: .init(
                    prompt: "a giant cat on the moon with bizarre eyes and small hands",
                    negativePrompt: String.sampleNegativePrompt,
                    stepCount: 8,
                    guidanceScale: 2.3,
                    seed: 52916723
                ),
                duration: 500.29385771865
            ),
        ],
        isErrorShown: Bool = false
    ) {
        self.state = state
        self.currentStep = currentStep
        self.storedImages = storedImages

        let info = ErrorInfo(title: "Ah crap", message: "Something blew up")
        errorInfo = isErrorShown ? info : nil
    }

    func generateImages() {}

    func cancelImageGeneration() {}

    func update(previewImage: UIImage?, shouldResetState: Bool) {}

    func deleteImages(at offsets: IndexSet) {}

    func moveImages(from source: IndexSet, to destination: Int) {}
}
