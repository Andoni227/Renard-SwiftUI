//
//  ShareUtility.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 05/11/25.
//

import SwiftUI

struct ShareUtility: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
