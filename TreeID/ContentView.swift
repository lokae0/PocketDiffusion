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
    @State private var selectedImage: Image? = nil

    var body: some View {
        let cornerRadius = Constants.cornerRadius

        VStack {
            if let image = selectedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(cornerRadius)
            }

            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Pick a Photo", systemImage: "photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(cornerRadius)
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = Image(uiImage: uiImage)
                    } else {
                        selectedImage = nil
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
