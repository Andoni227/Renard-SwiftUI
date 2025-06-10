//
//  LottieView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 05/06/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = loopMode
        view.play()
        view.contentMode = .scaleAspectFit 
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func updateUIView(_ uiView: Lottie.LottieAnimationView, context: Context) { }
}
