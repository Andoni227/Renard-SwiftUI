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
    var showLabel: Bool
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                LottieView(name: "black_cat", loopMode: .loop)
                    .frame(width: 200.0, height: 200.0)
                    .padding()
                Spacer()
            }
            ProgressView(value: progress)
                .padding()
                .padding(.horizontal, 100.0)
                .tint(.green)
            RNRDText(text: "loading")
        }
    }
}
