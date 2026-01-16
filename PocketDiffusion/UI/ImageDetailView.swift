//
//  ImageDetailView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/14/26.
//

import SwiftUI

private extension UI {
    static let imageHeight: CGFloat = 512.0

    enum DoneIndicator {
        static let size: CGFloat = 24.0
        static let shadowRadius: CGFloat = 1.0

        static func frameSize(parentSize: CGSize) -> CGSize {
            let scalar = 0.85
            return .init(
                width: parentSize.width * scalar,
                height: parentSize.height * scalar
            )
        }
    }
}

struct ImageDetailView: View {

    var image: GeneratedImage

    @Binding var imageStore: GeneratedImageStoring

    // Used to navigate back to generation view
    @Binding var selectedTab: ContentView.TabType

    @State private var showCopyAlert: Bool = false
    @State private var showShareSheet: Bool = false

    private var settings: GenerationSettings {
        image.settings
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: UI.Spacing.large) {
                NavigationLink(destination: ZoomableImageView(uiImage: image.uiImage)) {
                    Image(uiImage: image.uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(UI.cornerRadius)
                        .frame(maxWidth: UI.imageHeight, maxHeight: UI.imageHeight)
                        .centeredInFrame()
                }

                promptLabels(title: "Prompt", content: settings.prompt)
                
                promptLabels(title: "Negative prompt", content: settings.negativePrompt)

                numberLabels
            }
            .padding(UI.Spacing.medium)
        }
        .toolbar {
            copyToolBarItem
            shareToolBarItem
        }
        .scrollIndicators(.hidden)
    }

    private func replaceCurrentSettings() {
        imageStore.prompt = settings.prompt
        imageStore.negativePrompt = settings.negativePrompt
        imageStore.guidanceScale = settings.guidanceScale
        imageStore.stepCount = settings.stepCount
        imageStore.seed = Int(settings.seed)

        imageStore.update(previewImage: image.uiImage, shouldResetState: true)
    }
}

private extension ImageDetailView {

    @ViewBuilder
    private func promptLabels(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            Text(title)
                .font(.system(.headline))
            Text(content)
        }
    }

    @ViewBuilder
    private var numberLabels: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            Text("Steps: \(settings.stepCount)")
                .fontWeight(.medium)
            let guidanceFormat = String(format: "%.1f", arguments: [settings.guidanceScale])
            Text("Guidance scale: \(guidanceFormat)")
                .fontWeight(.medium)
            Text("Seed: \(Int(settings.seed))")
                .fontWeight(.medium)
            Text("Generated in: \(image.durationString)")
                .fontWeight(.medium)
        }
    }

    @ToolbarContentBuilder
    private var copyToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showCopyAlert = true
            } label: {
                Label("Copy", systemImage: UI.Symbol.copy)
            }
            .alert("Copy these settings to the Generate tab?", isPresented: $showCopyAlert) {
                Button(role: .confirm) {
                    replaceCurrentSettings()
                    selectedTab = .imageGeneration
                } label: {
                    Text("Proceed")
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will replace all current settings!")
            }
        }
    }

    @ToolbarContentBuilder
    private var shareToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                showShareSheet = true
            } label: {
                Label("Share", systemImage: UI.Symbol.share)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetViewController(activityItems: [image.uiImage])
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: ContentView.TabType = .imageGallery
    @Previewable @State var previewImageStore: any GeneratedImageStoring = PreviewImageStore()

    @Previewable var generatedImage: GeneratedImage = .init(
        uiImage: .image(color: .darkGray),
        settings: .init(
            prompt: String.samplePrompt,
            negativePrompt: String.sampleNegativePrompt,
            stepCount: 50,
            guidanceScale: 15.0,
            seed: UInt32.max
        ),
        duration: 5.897
    )
    ImageDetailView(
        image: generatedImage,
        imageStore: $previewImageStore,
        selectedTab: $selectedTab
    )
}
