//
//  ImagePicker.swift
//  TreeID
//
//  Created by Ian Luo on 12/26/25.
//

import UIKit

struct Tree: Identifiable, Hashable {

    let id: UUID = .init()
    let name: String
    let confidence: Double
    let image: UIImage
}
