//
//  ClassificationModeling.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

struct ClassificationResult {
    let label: String
    let confidence: Double
}

protocol ClassificationModeling {

    func classify(image: UIImage) async -> [ClassificationResult]
}
