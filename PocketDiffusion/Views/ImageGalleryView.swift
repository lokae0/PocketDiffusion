//
//  ImageGalleryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let itemHeight: CGFloat = 200.0
}

struct ImageGalleryView: View {

    @Binding var imageStore: GeneratedImageStoring

    var body: some View {
        if imageStore.generatedImages.isEmpty == false {
            List {
                ForEach(imageStore.generatedImages) { generatedImage in
                    Image(uiImage: generatedImage.uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: UI.itemHeight)
                        .cornerRadius(UI.cornerRadius)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGalleryView(imageStore: $previewImageStore)
}
