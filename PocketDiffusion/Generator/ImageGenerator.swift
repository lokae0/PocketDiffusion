//
//  ImageGenerator.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import CoreML
import StableDiffusion
import UIKit

protocol Generating: Actor {

    associatedtype Generated: Sendable
    typealias GenerationStream = AsyncThrowingStream<Generated, Error>

    /// Loads models if required and begins generation when ready
    func generate(with settings: GenerationSettings) -> GenerationStream
}

final actor ImageGenerator: Generating {

    typealias Generated = (image: UIImage, step: Int)

    private let pipeline: StableDiffusionPipeline

    private let loggingPrefix: String = "IG - "

    private var cancellationMessage: String {
        loggingPrefix + "Generation cancelled"
    }

    init() {
        let fatalLoadMessage = loggingPrefix + "Unable to load Stable Diffusion model resources"

        guard let modelUrl = Bundle.main.url(
            forResource: "coreml-stable-diffusion-v1-5-palettized_split_einsum_v2_compiled",
            withExtension: nil
        ) else {
            Log.shared.fatal(fatalLoadMessage)
        }
        do {
            Log.shared.currentThread(loggingPrefix + "Setting up image generator pipeline")

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
                await prewarm()
            }
            Log.shared.currentThread(
                loggingPrefix + "Ending image generator setup",
                isEnabled: false
            )
        } catch {
            Log.shared.fatal(fatalLoadMessage)
        }
    }

    func generate(with settings: GenerationSettings) -> GenerationStream {
        AsyncThrowingStream { continuation in
            let config = configuration(for: settings)

            let generationTask = Task {
                await Timer.shared.stopTimer(type: .awaitingPipeline)

                // Handle cancellations that occur during prewarming
                guard !Task.isCancelled else {
                    Log.shared.info(cancellationMessage)
                    return
                }
                Log.shared.currentThread(
                    loggingPrefix + "Calling `pipeline.generateImages` with settings: \(settings)"
                )
                await Timer.shared.startTimer(type: .imageGeneration)
                await invokePipeline(with: config, continuation: continuation)
            }

            continuation.onTermination = { [weak self] termination in
                self?.cancel(task: generationTask, upon: termination)
            }
        }
    }
}

private extension ImageGenerator {

    func prewarm() async {
        do {
            Log.shared.currentThread("Prewarming started")
            try pipeline.prewarmResources()
        } catch {
            Log.shared.info("Prewarming failed!!")
        }
    }

    func configuration(
        for settings: GenerationSettings
    ) -> StableDiffusionPipeline.Configuration {
        var config = StableDiffusionPipeline.Configuration(prompt: settings.prompt)
        config.negativePrompt = settings.negativePrompt
        config.stepCount = settings.stepCount
        config.guidanceScale = Float(settings.guidanceScale)
        config.seed = settings.seed
        config.useDenoisedIntermediates = true
        config.schedulerType = .dpmSolverMultistepScheduler
        return config
    }

    func invokePipeline(
        with config: StableDiffusionPipeline.Configuration,
        continuation: GenerationStream.Continuation
    ) async {
        do {
            let _ = try pipeline.generateImages(configuration: config) { progress in
                // Handle cancellations that occur during image generation
                guard !Task.isCancelled else {
                    Log.shared.info(cancellationMessage)
                    continuation.finish()
                    return false
                }
                // Return stream of images as they're generated
                if let currentImage = progress.currentImages.compactMap({ $0 }).last {
                    Log.shared.info(loggingPrefix + "Step: \(progress.step)")
                    let image = UIImage(cgImage: currentImage)
                    continuation.yield((image, progress.step))
                }
                // Check if we're done
                if progress.step == progress.stepCount - 1 {
                    Log.shared.info(loggingPrefix + "Finished generating")
                    continuation.finish()
                }
                return true
            }
        } catch {
            continuation.finish(throwing: error)
        }
    }

    nonisolated func cancel(
        task: Task<(), Never>,
        upon termination: (GenerationStream.Continuation.Termination)
    ) {
        switch termination {
        case .cancelled:
            Log.shared.currentThread(
                loggingPrefix + "`continuation.onTermination` canceling generationTask"
            )
            task.cancel()
        case .finished:
            break
        @unknown default:
            break
        }
    }
}
