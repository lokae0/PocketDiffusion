//
//  Generator.swift
//  TreeID
//
//  Created by Ian Luo on 1/6/26.
//

import Foundation
import StableDiffusion

protocol Generating {
    func generate()
}

class Generator: Generating {

    let pipeline: StableDiffusionPipeline

    init() {
        let loadErrorMessage = "Unable to load Stable Diffusion model resources"

        guard let modelUrl = Bundle.main.url(forResource: "StableDiffusionModel", withExtension: nil) else {
            fatalError(loadErrorMessage)
        }
        do {
            pipeline = try .init(
                resourcesAt: modelUrl,
                controlNet: [],
                disableSafety: true,
                reduceMemory: true
            )
            print(modelUrl)

        } catch {
            fatalError(loadErrorMessage)
        }
    }

    func generate() {

    }
}
