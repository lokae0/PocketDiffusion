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
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var treeStore: TreeStore = .init()

    var body: some View {
        let cornerRadius = Constants.cornerRadius

        VStack {
            if treeStore.trees.isEmpty == false {
                List {
                    ForEach(treeStore.trees) { tree in
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

            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("", systemImage: "photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(cornerRadius)
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                // TODO: abstract to separate handler
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        treeStore.addTree(for: uiImage)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
