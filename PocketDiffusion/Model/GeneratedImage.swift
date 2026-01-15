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
    let settings: GenerationSettings
    let duration: TimeInterval

    var durationString: String {
        let format = String(format: "%.1f", arguments: [duration])
        return format + "s"
    }
}

extension GeneratedImage: Codable {

    enum CodingKeys: String, CodingKey {
        case id, uiImage, settings, duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.settings = try container.decode(GenerationSettings.self, forKey: .settings)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)

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
        try container.encode(settings, forKey: .settings)
        try container.encode(duration, forKey: .duration)

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
