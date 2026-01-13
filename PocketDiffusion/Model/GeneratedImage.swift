//
//  Image.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

struct GeneratedImage: Identifiable, Hashable, Sendable {
    private(set) var id: UUID = .init()
    let uiImage: UIImage
    let params: GenerationParameters
}

extension GeneratedImage: Codable {

    enum CodingKeys: String, CodingKey {
        case id, uiImage, params
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.params = try container.decode(GenerationParameters.self, forKey: .params)

        let imageData = try container.decode(Data.self, forKey: .uiImage)
        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(
                forKey: .uiImage,
                in: container,
                debugDescription: "Image data could not be decoded as UIImage"
            )
        }
        self.uiImage = image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(params, forKey: .params)

        guard let imageData = uiImage.pngData() else {
            throw EncodingError.invalidValue(
                uiImage,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "UIImage could not be encoded as PNG"
                )
            )
        }
        try container.encode(imageData, forKey: .uiImage)
    }
}
