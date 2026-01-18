//
//  UIConstants.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import SwiftUI

enum UI {
    static let cornerRadius: CGFloat = 16.0
    static let tintColor: Color = .pink

    enum Spacing {
        static let extraSmall: CGFloat = 4.0
        static let small: CGFloat = 8.0
        static let medium: CGFloat = 16.0
        static let large: CGFloat = 32.0
        static let extraLarge: CGFloat = 48.0
    }

    enum Symbol {
        static let generate = "wand.and.sparkles"
        static let gallery = "photo.on.rectangle"
        static let checkmark = "checkmark"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let eraser = "eraser"
        static let xmark = "xmark"
        static let plus = "plus"
        static let minus = "minus"
        static let copy = "wand.and.sparkles.inverse"
        static let share = "square.and.arrow.up"
    }
}
