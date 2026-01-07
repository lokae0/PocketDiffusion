//
//  ContentView.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 11/25/25.
//

import SwiftUI

struct ContentView: View {

    enum TabType: CaseIterable, Identifiable {
        case imageGeneration
        case imageGallery

        var label: String {
            switch self {
            case .imageGeneration: "Generate"
            case .imageGallery: "Gallery"
            }
        }

        var systemImage: String {
            switch self {
            case .imageGeneration: "wand.and.sparkles"
            case .imageGallery: "photo.on.rectangle"
            }
        }

        @ViewBuilder
        func view(with imageStore: Binding<GeneratedImageStoring>) -> some View {
            switch self {
            case .imageGeneration: ImageGenerationView(imageStore: imageStore)
            case .imageGallery: ImageGalleryView(imageStore: imageStore)
            }
        }

        var id: Self { self }
    }

    @State private var imageStore: GeneratedImageStoring = GeneratedImageStore()
    @State private var selectedTab: TabType = .imageGeneration

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases) { type in
                Tab(
                    type.label,
                    systemImage: type.systemImage,
                    value: type
                ) {
                    type.view(with: $imageStore)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
