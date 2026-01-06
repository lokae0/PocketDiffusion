//
//  TreeStore.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import Foundation
import UIKit

@Observable
class TreeStore {
    var trees: [Tree] = []
    let classificationModel: VisionClassificationModel = .init()

    func addTree(for image: UIImage) {
        Task {
            let classifications = await classificationModel.classify(image: image)
            guard !classifications.isEmpty else {
                return
            }
            trees = classifications.map {
                Tree(
                    name: $0.label,
                    confidence: $0.confidence,
                    image: image
                )
            }
        }
    }
}
