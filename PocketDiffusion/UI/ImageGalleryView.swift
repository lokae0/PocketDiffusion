//
//  ImageGalleryView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

private extension UI {
    static let cellHeight: CGFloat = 160.0
    static let minScaleFactor: CGFloat = 0.85

    enum Number {
        static let shadowRadius: CGFloat = 3.0
        static let bgSize: CGFloat = 20.0
    }

    static var numberFrameSize: CGFloat {
        cellHeight * 5/6
    }
}

struct ImageGalleryView: View {

    @Binding var imageStore: GeneratedImageStoring

    var body: some View {
        let imagesWithIndex = imageStore.storedImages.enumerated()

        List(imagesWithIndex, id: \.element.id) { index, storedImage in
            HStack(alignment: .top, spacing: UI.Spacing.medium) {
                ZStack {
                    Image(uiImage: storedImage.uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(UI.cornerRadius)

                    numberIcon(for: index)
                        .shadow(radius: UI.Number.shadowRadius)
                        .frame(
                            maxWidth: UI.numberFrameSize,
                            maxHeight: UI.numberFrameSize,
                            alignment: .topLeading
                        )
                }

                labels(for: storedImage)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: UI.cellHeight)
            .fixedSize(horizontal: false, vertical: true)
        }
        .listStyle(.plain)
    }
}

private extension ImageGalleryView {

    @ViewBuilder
    private func labels(for storedImage: GeneratedImage) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            Text(storedImage.params.prompt)
                .minimumScaleFactor(UI.minScaleFactor)
            Spacer()
            HStack {
                Text("Steps: \(storedImage.params.stepCount)")
                Spacer()
                Text(storedImage.durationString)
            }
        }
    }

    @ViewBuilder
    private func numberIcon(for index: Int) -> some View {
        ZStack {
            Image(uiImage: .image(color: .white))
                .frame(width: UI.Number.bgSize, height: UI.Number.bgSize)
                .cornerRadius(UI.Number.bgSize)

            Text("\(index + 1)")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()
    ImageGalleryView(imageStore: $previewImageStore)
}
