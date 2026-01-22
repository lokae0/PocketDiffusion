//
//  ZoomableImageView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/15/26.
//

import SwiftUI

private extension UI {
    static let animationDuration: CGFloat = 0.25
    static let minZoomScale: CGFloat = 1.0
    static let maxZoomScale: CGFloat = 5.0
}

struct ZoomableImageView: View {

    var uiImage: UIImage?

    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0

    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero

    @State private var imageSize: CGSize = .zero

    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: uiImage ?? .placeholder)
                .resizable()
                .scaledToFit()
                .scaleEffect(currentScale)
                .offset(currentOffset)
                .onGeometryChange(for: CGSize.self) { proxy in
                    return proxy.size
                } action: { newSize in
                    imageSize = newSize
                }
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            currentScale = finalScale * value.magnification
                        }
                        .onEnded { _ in
                            fixBounds()
                        }
                        .simultaneously(
                            with: DragGesture()
                                .onChanged { value in
                                    currentOffset = CGSize(
                                        width: finalOffset.width + value.translation.width,
                                        height: finalOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    fixBounds()
                                }
                        )
                )
                .onTapGesture(count: 2) {
                    // Double tap to zoom or unzoom
                    withAnimation(.easeInOut(duration: UI.animationDuration)) {
                        let hasNotZoomed = currentScale == 1.0
                        currentScale = hasNotZoomed ? 2.0 : 1.0
                        fixBounds()
                    }
                }

            Spacer()
        }
    }

    private func fixBounds() {
        withAnimation(.spring) {
            // Snap back scale if too small or too large
            if currentScale < UI.minZoomScale {
                currentScale = UI.minZoomScale
            } else if currentScale > UI.maxZoomScale {
                currentScale = UI.maxZoomScale
            }

            // Calculate bounds based on new scale
            // The image "overflows" the screen by this amount on each side
            let extraWidth = (imageSize.width * currentScale - imageSize.width) / 2
            let extraHeight = (imageSize.height * currentScale - imageSize.height) / 2

            // Constrain offset so edges don't leave the screen
            // If scale is 1.0, extraWidth is 0, so offset snaps to .zero
            let restrictedWidth = min(max(currentOffset.width, -extraWidth), extraWidth)
            let restrictedHeight = min(max(currentOffset.height, -extraHeight), extraHeight)

            currentOffset = CGSize(width: restrictedWidth, height: restrictedHeight)

            // Save state for next gesture
            finalScale = currentScale
            finalOffset = currentOffset
        }
    }
}

struct ModalZoomableImageView: View {

    var uiImage: UIImage?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZoomableImageView(uiImage: uiImage)
                .toolbar {
                    dismissToolbarItem
                }
        }
    }
}

private extension ModalZoomableImageView {

    @ToolbarContentBuilder
    var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Label(String.Button.dismiss, systemImage: UI.Symbol.xmark)
            }
        }
    }
}

#Preview {
    @Previewable var uiImage: UIImage = .image(color: .systemGreen)
    ModalZoomableImageView(uiImage: uiImage)
}
