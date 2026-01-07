//
//  Generator.swift
//  TreeID
//
//  Created by Ian Luo on 1/6/26.
//

import CoreImage
import Foundation
import StableDiffusion

protocol Generating {
    func generate(prompt: String, negativePrompt: String) -> CGImage?
}

class Generator: Generating {

    let pipeline: StableDiffusionPipeline

    init() {
        let loadErrorMessage = "Unable to load Stable Diffusion model resources"

        guard let modelUrl = Bundle.main.url(forResource: "StableDiffusionModel", withExtension: nil) else {
            fatalError(loadErrorMessage)
        }
        do {
            self.pipeline = try .init(
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

    func generate(prompt: String, negativePrompt: String) -> CGImage? {
        var config = StableDiffusionPipeline.Configuration(prompt: prompt)
        config.negativePrompt = negativePrompt
        config.stepCount = 25
        config.guidanceScale = 11
        config.seed = UInt32.random(in: 0..<UInt32.max)
        config.schedulerType = .dpmSolverMultistepScheduler

        // TODO: handle errors
        let images = try! pipeline.generateImages(configuration: config) { progress in
            print(progress.step)
            return true
        }
        print("Got images: \(images)")

        // Unwrap the 1 image we asked for, nil means safety checker triggered
        return images
            .compactMap { $0 }
            .first
    }
}
