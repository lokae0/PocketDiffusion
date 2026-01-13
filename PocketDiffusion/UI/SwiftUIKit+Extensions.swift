//
//  UIImage+Color.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI
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

    static var placeholder: UIImage {
        .image(color: .gray)
    }
}

extension View {

    func centeredInFrame() -> some View {
        frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
    }
}

extension Binding {

    // https://medium.com/@matgnt/clean-alert-handling-in-swiftui-mapping-optionals-to-presentation-state-acb4df717c01
    static func isPresent<T>(_ source: Binding<T?>) -> Binding<Bool> {
        .init(
            get: {
                source.wrappedValue != nil
            },
            set: { newValue in
                if !newValue {
                    source.wrappedValue = nil
                }
            }
        )
    }
}
