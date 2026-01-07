//
//  Timer.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import StableDiffusion

// TODO: implement swift-dependencies for DI
final class Timer {

    static let shared = Timer()

    private init() {}

    enum `Type` {
        /// How long it takes to load models before image generation begins
        case modelLoading
        /// How long image generation takes
        case imageGeneration

        var label: String {
            switch self {
            case .imageGeneration: "Image generation"
            case .modelLoading: "Model loading"
            }
        }
    }

    private static let loadingTimer = SampleTimer()
    private static let generationTimer = SampleTimer()

    func startTimer(type: Type) {
        switch type {
        case .modelLoading:
            Self.loadingTimer.start()
        case .imageGeneration:
            Self.generationTimer.start()
        }
    }

    @discardableResult
    func stopTimer(type: Type, shouldLog: Bool = true) -> Double {
        let duration: Double

        switch type {
        case .modelLoading:
            duration = Self.loadingTimer.stop()
        case .imageGeneration:
            duration = Self.generationTimer.stop()
        }

        if shouldLog {
            Log.shared.info("\(type.label) duration: \(duration)s")
        }
        return duration
    }
}

