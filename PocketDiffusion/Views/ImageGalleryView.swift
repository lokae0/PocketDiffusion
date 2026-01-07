//
//  ImageGalleryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 200.0
}

struct ImageGalleryView: View {

    @Binding var imageStore: GeneratedImageStoring

    var body: some View {
        if imageStore.storedImages.isEmpty == false {
            List {
                ForEach(imageStore.storedImages) { storedImage in
                    Image(uiImage: storedImage.uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(UI.cornerRadius)
                        .frame(height: UI.imageHeight)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGalleryView(imageStore: $previewImageStore)
}
