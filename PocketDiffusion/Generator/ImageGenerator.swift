//
//  ImageGenerator.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import CoreML
import StableDiffusion
import UIKit

public protocol Generating: Actor {
    associatedtype Generated: Sendable
    func generate(prompt: String, negativePrompt: String) async -> Generated?
}

final actor ImageGenerator: Generating {

    typealias Generated = UIImage

    let pipeline: StableDiffusionPipeline

    init() {
        func logFatalLoadError() -> Never {
            Log.shared.fatal("Unable to load Stable Diffusion model resources")
        }

        guard let modelUrl = Bundle.main.url(forResource: "StableDiffusionModel", withExtension: nil) else {
            logFatalLoadError()
        }
        do {
            Log.shared.currentThread(for: "Starting image generator init")

            let mlConfig = MLModelConfiguration()
            mlConfig.computeUnits = .cpuAndNeuralEngine
            self.pipeline = try .init(
                resourcesAt: modelUrl,
                controlNet: [],
                configuration: mlConfig,
                disableSafety: true,
                reduceMemory: true
            )
            Task {
                try await prewarm()
            }
            Log.shared.currentThread(for: "Resuming image generator init")

        } catch {
            logFatalLoadError()
        }
    }

    func generate(prompt: String, negativePrompt: String) async -> Generated? {
        Log.shared.currentThread(for: "Generating images")

        var config = StableDiffusionPipeline.Configuration(prompt: prompt)
        config.negativePrompt = negativePrompt
        config.stepCount = 25
        config.guidanceScale = 11
        config.seed = UInt32.random(in: 0..<UInt32.max)
        config.schedulerType = .dpmSolverMultistepScheduler

        // TODO: handle errors
        let images = try! pipeline.generateImages(configuration: config) { progress in
            if progress.step == 0 {
                Task { @MainActor in
                    Timer.shared.stopTimer(type: .modelLoading)
                    Timer.shared.startTimer(type: .imageGeneration)
                }
            }
            Log.shared.info("Step: \(progress.step)")
            return true
        }
        Log.shared.info("Got images: \(images)")

        // Nil means safety checker triggered
        let cgImage = images
            .compactMap({ $0 })
            .first

        if let cgImage {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }

    private func prewarm() async throws {
        Log.shared.currentThread(for: "Prewarming started")
        try pipeline.prewarmResources()
    }
}

