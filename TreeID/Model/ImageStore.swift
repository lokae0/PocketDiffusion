//
//  ImageStore.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import Foundation
import UIKit

@Observable
class ImageStore {

    var trees: [Tree] = []
    private let generator: Generating

    init(generator: Generating = Generator()) {
        self.generator = generator
    }

    func handle(prompt: String, negatives: String) {

    }
}
