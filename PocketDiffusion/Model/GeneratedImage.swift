//
//  Image.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

public struct GeneratedImage: Identifiable, Hashable, Sendable {

    public let id: UUID = .init()
    let uiImage: UIImage

    let params: GenerationParameters
}
