//
//  GenerationParameters.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import Foundation

public struct GenerationParameters: Hashable, Sendable {

    let prompt: String
    let negativePrompt: String
    let stepCount: Int
    let guidanceScale: Double
    let seed: UInt32
}

extension GenerationParameters {

    static let defaultValues = Self(
        prompt: "",
        negativePrompt: "",
        stepCount: 25,
        guidanceScale: 11.0,
        seed: 0
    )
}
