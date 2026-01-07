//
//  Logger.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/6/26.
//

import Foundation

// TODO: implement swift-dependencies for DI
nonisolated final class Log: Sendable {

    static let shared = Log()

    private init() {}

    func info(_ message: String) {
        print(message)
    }

    func fatal(_ message: String) -> Never {
        fatalError(message)
    }

    func currentThread(for event: String) {
        print("\(event) on: \(Thread.current)")
    }
}

