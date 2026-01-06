//
//  GeneratedImageStore.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import Foundation
import UIKit

@Observable
class GeneratedImageStore {

    var generatedImages: [GeneratedImage] = []
    private let generator: Generating

    init(generator: Generating = Generator()) {
        self.generator = generator
    }

    func handle(prompt: String, negatives: String) {
        guard let cgImage = generator.generate() else {
            return
        }
        generatedImages.append(
            .init(uiImage: .init(cgImage: cgImage))
        )
    }
}
