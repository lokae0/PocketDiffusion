//
//  ZoomableImageView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/15/26.
//

import SwiftUI

private extension UI {
    static let animationDuration: CGFloat = 0.25
    static let maxZoomScale: CGFloat = 5.0
}

struct ZoomableImageView: View {

    var uiImage: UIImage

    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoomScale * gestureScale)
                    .frame(
                        width: geometry.size.width * (zoomScale * gestureScale),
                        height: geometry.size.height * (zoomScale * gestureScale)
                    )
                    .gesture(
                        MagnifyGesture()
                            .updating($gestureScale) { value, state, _ in
                                state = value.magnification
                            }
                            .onEnded { value in
                                zoomScale *= value.magnification

                                if zoomScale < 1.0 {
                                    withAnimation(.spring()) {
                                        zoomScale = 1.0
                                    }
                                }
                                if zoomScale >= UI.maxZoomScale {
                                    withAnimation(.spring()) {
                                        zoomScale = UI.maxZoomScale
                                    }
                                }
                            }
                    )
            }
            .scrollBounceBehavior(.basedOnSize)
            .onTapGesture(count: 2) {
                // Double tap to zoom or unzoom
                withAnimation(.easeInOut(duration: UI.animationDuration)) {
                    let hasNotZoomed = zoomScale == 1.0
                    zoomScale = hasNotZoomed ? 2.0 : 1.0
                }
            }
        }
    }
}

#Preview {
    @Previewable var uiImage: UIImage = .image(color: .systemGreen)
    ZoomableImageView(uiImage: uiImage)
}
