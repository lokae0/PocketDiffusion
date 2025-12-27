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
            guard let classification = await classificationModel.classify(image: image) else {
                return
            }
            let tree = Tree(
                name: classification.label,
                confidence: classification.confidence,
                image: image
            )
            trees.insert(tree, at: 0)
        }
    }
}
