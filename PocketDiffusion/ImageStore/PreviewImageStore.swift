//
//  PreviewImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import UIKit

@Observable
final class PreviewImageStore: GeneratedImageStoring {

    var state: GenerationState = .initial

    var previewImage: UIImage = .placeholder

    var storedImages: [GeneratedImage] = [
        .init(uiImage: .image(color: .darkGray), params: .defaultValues),
        .init(uiImage: .image(color: .lightGray), params: .defaultValues),
        .init(uiImage: .image(color: .gray), params: .defaultValues),
    ]

    func generateImages(with params: GenerationParameters) {}
}


