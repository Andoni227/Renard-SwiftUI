//
//  LoadingView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 07/06/25.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    @Binding var progress: Double
    
    var body: some View {
        VStack{
            LottieView(name: "black_cat", loopMode: .loop)
                .frame(width: 200.0, height: 200.0)
                .padding()
            ProgressView(value: progress)
                .padding()
                .tint(.green)
        }
    }
}
