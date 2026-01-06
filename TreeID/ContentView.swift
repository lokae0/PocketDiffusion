//
//  ContentView.swift
//  TreeID
//
//  Created by Ian Luo on 11/25/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {

    private enum Constants {
        static let cornerRadius: CGFloat = 16.0
    }

    @State private var imageStore: GeneratedImageStore = .init()

    var body: some View {
        let cornerRadius = Constants.cornerRadius

        VStack {
            if imageStore.generatedImages.isEmpty == false {
                List {
                    ForEach(imageStore.generatedImages) { generatedImage in
                        Image(uiImage: generatedImage.uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(cornerRadius)
                        
//                        Text("Name: \(tree.name)")
//                        Text("Confidence: \(tree.confidence)")
                    }
                }
            }

            Button("Generate", role: nil) {
                imageStore.handle(prompt: "abc", negatives: "aaa")
            }
        }
    }
}

#Preview {
    ContentView()
}
