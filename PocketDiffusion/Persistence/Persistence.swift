//
//  Persistence.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/12/26.
//

import Foundation

protocol Persisting: Actor {

    associatedtype Model

    func save(model: Model) throws(PersistenceError)

    func restore() throws(PersistenceError) -> Model
}

enum PersistenceError: Error {
    case save, restore

    var defaultInfo: ErrorInfo {
        switch self {
            case .save:
            return .init(
                title: "Failed to save image",
                message: "Please try generating again"
            )
        case .restore:
            return .init(
                title: "Failed to restore images",
                message: "Please restart the app"
            )
        }
    }
}

actor FilePersistence: Persisting {

    typealias Model = [GeneratedImage]

    private var fileManager: FileManager {
        FileManager.default
    }

    private var folderUrl: URL {
        guard let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            Log.shared.fatal("Unable to load documents directory")
        }
        return dir.appendingPathComponent("GeneratedImages")
    }

    private var fileUrl: URL {
        folderUrl.appendingPathComponent("saved.json")
    }

    func save(model: Model) throws(PersistenceError) {
        Log.shared.currentThread("Saving to disk", isEnabled: false)
        do {
            // No-op if directory already exists
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let data = try JSONEncoder().encode(model)
            // Overwrites file if it already exists
            fileManager.createFile(atPath: fileUrl.path, contents: data)
            Log.shared.info("Images successfully saved to disk")
        } catch {
            Log.shared.info("Error while saving: \(error.localizedDescription)")
            throw .save
        }
    }

    func restore() throws(PersistenceError) -> Model {
        Log.shared.currentThread("Restoring from disk", isEnabled: false)

        guard fileManager.fileExists(atPath: fileUrl.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            let model = try JSONDecoder().decode(Model.self, from: data)
            Log.shared.info("Images successfully restored from disk")
            return model
        } catch {
            Log.shared.info("Error while restoring: \(error.localizedDescription)")
            throw .restore
        }
    }
}
