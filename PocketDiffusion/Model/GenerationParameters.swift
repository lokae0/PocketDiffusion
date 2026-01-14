//
//  GenerationParameters.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import Foundation

struct GenerationParameters: Sendable, Codable {

    let prompt: String
    let negativePrompt: String
    let stepCount: Int
    let guidanceScale: Double
    let seed: UInt32
}
