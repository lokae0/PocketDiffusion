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

    var previewImage: UIImage

    var currentStep: Int?

    var storedImages: [GeneratedImage]

    var errorInfo: ErrorInfo?

    init(
        state: GenerationState = .idle,
        previewImage: UIImage = .placeholder,
        currentStep: Int? = 3,
        storedImages: [GeneratedImage] = [
            .init(
                uiImage: .image(color: .darkGray),
                params: .init(
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
                params: .init(
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
                params: .init(
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
        self.previewImage = previewImage
        self.currentStep = currentStep
        self.storedImages = storedImages

        let info = ErrorInfo(title: "Ah crap", message: "Something blew up")
        errorInfo = isErrorShown ? info : nil
    }

    func generateImages(with params: GenerationParameters) {}

    func cancelImageGeneration() {}
}
