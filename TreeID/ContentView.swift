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

    @State private var imageStore: ImageStore = .init()

    var body: some View {
        let cornerRadius = Constants.cornerRadius

        VStack {
            if imageStore.trees.isEmpty == false {
                List {
                    ForEach(imageStore.trees) { tree in
                        Image(uiImage: tree.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(cornerRadius)
                        
                        Text("Name: \(tree.name)")
                        Text("Confidence: \(tree.confidence)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
