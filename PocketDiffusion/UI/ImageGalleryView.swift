//
//  ImageGalleryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let cellHeight: CGFloat = 160.0
}

struct ImageGalleryView: View {

    @Binding var imageStore: GeneratedImageStoring

    var body: some View {
        List(imageStore.storedImages) { storedImage in
            HStack(alignment: .top, spacing: UI.Spacing.medium) {
                Image(uiImage: storedImage.uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(UI.cornerRadius)

                VStack(alignment: .leading, spacing: UI.Spacing.small) {
                    Text(storedImage.params.prompt)
                        .minimumScaleFactor(0.85)

                    Spacer()

                    Text("Steps: \(storedImage.params.stepCount)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: UI.cellHeight)
            .fixedSize(horizontal: false, vertical: true)
        }
        .listStyle(.plain)
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGalleryView(imageStore: $previewImageStore)
}
