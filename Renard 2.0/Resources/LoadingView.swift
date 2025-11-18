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
    @Binding var progressTitle: LocalizedStringKey
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
            RNRDText(text: progressTitle)
            RNRDText(text: "closeApp")
                .padding(5.0)
                .padding(.horizontal, 45.0)
        }
    }
}

#Preview {
    let fakeProgress = Binding.constant(0.5)
    let fakeProgressTitle = Binding.constant(LocalizedStringKey("loading"))
    LoadingView(progress: fakeProgress, progressTitle: fakeProgressTitle, showLabel: true)
}
