//
//  VisionClassificationModel.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit
import Vision

struct VisionClassificationModel: ClassificationModelable {

    func classify(image: UIImage) async -> ClassificationResult? {
        guard let data = image.pngData() else {
            return nil
        }
        var request = ClassifyImageRequest()
        request.cropAndScaleAction = .centerCrop

        do {
            let results = try await request.perform(on: data)
                .filter {
                    // Only include classifications that meet a minimum precision and recall threshold
                    $0.hasMinimumPrecision(0.1, forRecall: 0.8)
                }

            guard let bestResult = results.first else {
                return nil
            }
            return .init(label: bestResult.identifier, confidence: Double(bestResult.confidence))
        }
        catch {
            print("Image classification error: \(error)")
            return nil
        }
    }
}
