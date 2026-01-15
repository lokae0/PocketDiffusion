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

    func errorInfoAlert(for imageStore: Binding<GeneratedImageStoring>) -> some View {
        alert(
            imageStore.wrappedValue.errorInfo?.title ?? "Oh no",
            isPresented: .isPresent(imageStore.errorInfo),
            presenting: imageStore.wrappedValue.errorInfo
        ) { _ in
            // Default 'OK' button is included
        } message: { info in
            Text(info.message)
        }
    }
}

extension Binding {

    // https://medium.com/@matgnt/clean-alert-handling-in-swiftui-mapping-optionals-to-presentation-state-acb4df717c01
    static func isPresent<T>(_ source: Binding<T?>) -> Binding<Bool> where Value == Bool {
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

    static func fromInt(_ source: Binding<Int>) -> Binding<Double> where Value == Double {
        .init(
            get: { Double(source.wrappedValue) },
            set: { source.wrappedValue = Int($0) }
        )
    }
}
