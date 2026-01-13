//
//  PocketDiffusionApp.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 11/25/25.
//

import SwiftUI

@main
struct PocketDiffusionApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    clearAppCache()
                }
        }
    }

    private func clearAppCache() {
        guard let cacheURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            Log.shared.info("Could not find cache directory URL")
            return
        }

        let fileManager = FileManager.default

        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: nil,
                options: []
            )

            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                    Log.shared.info("Deleted: \(file.lastPathComponent)")
                } catch let error as NSError {
                    Log.shared.info(
                        "Error deleting \(file.lastPathComponent): \(error.localizedDescription)"
                    )
                }
            }
        } catch {
            Log.shared.info(
                "Error accessing cache directory: \(error.localizedDescription)"
            )
        }
    }
}

