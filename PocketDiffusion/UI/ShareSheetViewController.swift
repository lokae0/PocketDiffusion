//
//  ShareSheetViewController.swift
//  PocketDiffusion
//
//  Created by Ian Luo on 1/15/26.
//

import SwiftUI

struct ShareSheetViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareSheetViewController>
    ) -> UIActivityViewController {
        .init(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ShareSheetViewController>
    ) {}
}
