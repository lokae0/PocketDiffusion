//
//  PreviewImageStore.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import UIKit

private extension UI {
    static let imageSize: CGFloat = 512.0
}

@Observable
final class PreviewImageStore: GeneratedImageStoring {

    var currentGeneration: GeneratedImage? = .init(uiImage: image(color: .gray))

    var storedImages: [GeneratedImage] = [
        .init(uiImage: image(color: .darkGray)),
        .init(uiImage: image(color: .lightGray)),
        .init(uiImage: image(color: .gray)),
    ]

    func handle(prompt: String, negativePrompt: String) {}

    private static func image(color: UIColor) -> UIImage {
        let size = CGSize(width: UI.imageSize, height: UI.imageSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image
    }
}
