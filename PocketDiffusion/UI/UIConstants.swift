//
//  UIConstants.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/7/26.
//

import Foundation

enum UI {
    static let cornerRadius: CGFloat = 16.0

    enum Spacing {
        static let small: CGFloat = 8.0
        static let medium: CGFloat = 16.0
        static let large: CGFloat = 32.0
    }

    enum Symbol {
        static let checkmark = "checkmark"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let eraser = "eraser"
        static let xmark = "xmark"
    }
}

extension String {

    static let promptPlaceholder: String = "Tap to edit..."

    static let samplePrompt: String = "cartoon character of a person with a hoodie , in style of cytus and deemo, ork, gold chains, realistic anime cat, dripping black goo, lineage revolution style, thug life, cute anthropomorphic bunny, balrog, arknights, aliased, very buff, black and red and yellow paint, painting illustration collage style, character composition in vector with white background"
}
