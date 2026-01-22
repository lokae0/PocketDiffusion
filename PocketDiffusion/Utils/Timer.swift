//
//  Timer.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import Foundation
import StableDiffusion

final class Timer {

    static let shared = Timer()

    private init() {}

    enum `Type` {
        /// How long it takes to load models or other preparation before pipeline is ready
        case awaitingPipeline
        /// How long image generation takes
        case imageGeneration

        var label: String {
            switch self {
            case .imageGeneration: "Image generation"
            case .awaitingPipeline: "Awaiting pipeline"
            }
        }
    }

    private static let loadingTimer = SampleTimer()
    private static let generationTimer = SampleTimer()

    func startTimer(type: Type, shouldLog: Bool = true) {
        switch type {
        case .awaitingPipeline:
            Self.loadingTimer.start()
        case .imageGeneration:
            Self.generationTimer.start()
        }
        if shouldLog {
            Log.shared.info("\(type.label) timer started")
        }
    }

    @discardableResult
    func stopTimer(type: Type, shouldLog: Bool = true) -> Double {
        let duration: Double

        switch type {
        case .awaitingPipeline:
            duration = Self.loadingTimer.stop()
        case .imageGeneration:
            duration = Self.generationTimer.stop()
        }

        if shouldLog {
            let formatString = String(format: "%.2f", arguments: [duration])
            Log.shared.info("\(type.label) duration: \(formatString)s")
        }
        return duration
    }
}

