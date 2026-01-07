//
//  GeneratedImageStore.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import Foundation
import UIKit

@Observable
final class GeneratedImageStore {

    var generatedImages: [GeneratedImage] = []
    private let imageGenerator: any Generating

    init(imageGenerator: any Generating = ImageGenerator()) {
        self.imageGenerator = imageGenerator
    }

    func handle(prompt: String, negativePrompt: String) async {
        guard let uiImage = await imageGenerator.generate(
            prompt: prompt,
            negativePrompt: negativePrompt
        ) as? UIImage else {
            return
        }
        Timer.shared.stopTimer(type: .imageGeneration)

        generatedImages.append(
            .init(uiImage: uiImage)
        )
    }
}
