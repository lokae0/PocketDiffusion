//
//  VisionClassificationModel.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit
import Vision

struct VisionClassificationModel: ClassificationModeling {

    func classify(image: UIImage) async -> [ClassificationResult] {
        guard let cgImage = image.cgImage else {
            return []
        }
        do {
            let mlModel = try INatVisionClassifier(configuration: .init()).model
            let visionModel = try VNCoreMLModel(for: mlModel)

            var results: [VNClassificationObservation] = []
            let request = VNCoreMLRequest(
                model: visionModel,
                completionHandler: { request, error in
                    guard let requestResults = request.results as? [VNClassificationObservation] else {
                        // TODO: throw error
                        return
                    }
                    results = requestResults
                })
            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([request])

            return results
                .prefix(10)
                .compactMap {
                    .init(label: $0.identifier, confidence: Double($0.confidence))
                }
        } catch {
            print("Vision classification error: \(error)")
            return []
        }
    }
}
