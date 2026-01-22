//
//  Logger.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import Foundation

nonisolated final class Log: Sendable {

    static let shared = Log()

    private var currentTime: String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: currentDate)
    }

    private init() {}

    func info(_ message: String) {
        print("\(currentTime) \(message)")
    }

    func fatal(_ message: String) -> Never {
        fatalError("\(currentTime) \(message)")
    }

    func currentThread(_ event: String, isEnabled: Bool = true) {
        if isEnabled {
            print("\(currentTime) \(event) on: \(Thread.current)")
        }
    }
}

