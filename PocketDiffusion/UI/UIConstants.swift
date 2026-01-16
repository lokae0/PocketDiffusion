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

extension String {

    static let promptPlaceholder: String = "Tap to edit..."

    static let samplePrompt: String = "cartoon character of a person with a hoodie , in style of cytus and deemo, ork, gold chains, realistic anime cat, dripping black goo, lineage revolution style, thug life, cute anthropomorphic bunny, balrog, arknights, aliased, very buff, black and red and yellow paint, painting illustration collage style, character composition in vector with white background"

    static let sampleNegativePrompt: String = "(((duplicate))), ((morbid)), ((mutilated)), out of frame, extra fingers, mutated hands, ((poorly drawn hands)), ((poorly drawn face)), (((mutation))), (((deformed))), blurry, ((bad anatomy)), (((bad proportions))), ((extra limbs)), cloned face, (((disfigured))), out of frame, ugly, extra limbs, (bad anatomy), gross proportions, (malformed limbs), ((missing arms)), ((missing legs)), (((extra arms))), (((extra legs))), mutated hands, (fused fingers), (too many fingers), (((long neck)))"
}
