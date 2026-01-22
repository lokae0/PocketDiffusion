//
//  Strings.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/17/26.
//

import Foundation

extension String {

    static let promptPlaceholder = String(localized: "Tap to edit...")
    static let cancelAlertTitle = String(localized: "Discard changes?")
    static let fallbackErrorTitle = String(localized: "Oh no")

    enum Settings {
        static let prompt = String(localized: "Prompt")
        static let negativePrompt = String(localized: "Negative prompt")
        static let stepCount = String(localized: "Step count")
        static let guidanceScale = String(localized: "Guidance scale")
        static let seed = String(localized: "Seed")

        static func displayLabel(stepCount: Int) -> String {
            .init(localized: "Steps: \(stepCount)")
        }

        static func displayLabel(guidance: Double) -> String {
            let guidanceFormat = format(guidanceScale: guidance)
            return .init("Guidance scale: \(guidanceFormat)")
        }

        static func displayLabel(seed: UInt32) -> String {
            .init(localized: "Seed: \(Int(seed))")
        }

        static func displayLabel(duration: String) -> String {
            .init(localized: "Generated in: \(duration)")
        }
    }

    enum Button {
        static let cancel = String(localized: "Cancel")
        static let nevermind = String(localized: "Nevermind")
        static let discard = String(localized: "Discard")
        static let dismiss = String(localized: "Dismiss")

        static let confirm = String(localized: "Confirm")
        static let proceed = String(localized: "Proceed")

        static let copy = String(localized: "Copy")
        static let share = String(localized: "Share")
        static let save = String(localized: "Save")
        static let erase = String(localized: "Erase")

        static let generate = String(localized: "Generate")
        static let gallery = String(localized: "Gallery")
    }

    enum UserDefaultsKeys {
        static let prompt = "prompt"
        static let negativePrompt = "negativePrompt"
        static let stepCount = "stepCount"
        static let guidanceScale = "guidanceScale"
        static let seed = "seed"
        static let isSeedRandom = "isSeedRandom"
    }

    static func format(guidanceScale: Double) -> String {
        .init(format: "%.1f", arguments: [guidanceScale])
    }
}

// For previews, tests, etc.
extension String {
    enum Mock {
        static let samplePrompt: String = "cartoon character of a person with a hoodie , in style of cytus and deemo, ork, gold chains, realistic anime cat, dripping black goo, lineage revolution style, thug life, cute anthropomorphic bunny, balrog, arknights, aliased, very buff, black and red and yellow paint, painting illustration collage style, character composition in vector with white background"

        static let sampleNegativePrompt: String = "(((duplicate))), ((morbid)), ((mutilated)), out of frame, extra fingers, mutated hands, ((poorly drawn hands)), ((poorly drawn face)), (((mutation))), (((deformed))), blurry, ((bad anatomy)), (((bad proportions))), ((extra limbs)), cloned face, (((disfigured))), out of frame, ugly, extra limbs, (bad anatomy), gross proportions, (malformed limbs), ((missing arms)), ((missing legs)), (((extra arms))), (((extra legs))), mutated hands, (fused fingers), (too many fingers), (((long neck)))"
    }
}
