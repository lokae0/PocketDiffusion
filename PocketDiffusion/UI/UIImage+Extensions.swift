//
//  UIImage+Color.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import UIKit

private extension UI {
    static let imageSize: CGFloat = 512.0
}

extension UIImage {
    static func image(color: UIColor) -> UIImage {
        let size = CGSize(width: UI.imageSize, height: UI.imageSize)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image
    }
}
