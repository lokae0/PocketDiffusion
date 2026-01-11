//
//  PreviewImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import UIKit

@Observable
final class PreviewImageStore: GeneratedImageStoring {

    var state: GenerationState = .idle

    var previewImage: UIImage = .placeholder

    var storedImages: [GeneratedImage] = [
        .init(
            uiImage: .image(color: .darkGray),
            params: .init(
                prompt: String.samplePrompt,
                negativePrompt: "",
                stepCount: 25,
                guidanceScale: 11.0,
                seed: 0
            )
        ),
        .init(
            uiImage: .image(color: .lightGray),
            params: .init(
                prompt: "a giant cat on the moon",
                negativePrompt: "weird eyes, no hands, big feet",
                stepCount: 8,
                guidanceScale: 2.3,
                seed: UInt32.max
            )
        ),
        .init(
            uiImage: .image(color: .gray),
            params: .init(
                prompt: "a giant cat on the moon with bizarre eyes and small hands",
                negativePrompt: String.sampleNegativePrompt,
                stepCount: 8,
                guidanceScale: 2.3,
                seed: 52916723
            )
        ),
    ]

    func generateImages(with params: GenerationParameters) {}

    func cancelImageGeneration() {}
}
