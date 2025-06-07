//
//  PhotoPreview.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 04/06/25.
//

import SwiftUI
import Lottie

struct PhotoPreview: View {
    @StateObject private var viewModel = PhotoPreviewViewModel()
    @Environment(\.dismiss) var dismiss
    let asset: AssetObject
    
    var body: some View {
        ZStack{
            Color.renardBackgroundHeavy
                .padding(.top, -30)
            if let img = viewModel.imgPreview{
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 100.0)
            }else{
                LottieView(name: "black_cat", loopMode: .loop)
                    .padding(100.0)
                    .padding(.bottom, 100.0)
            }
            
            VStack(spacing: 0.0){
                Spacer()
                HStack{
                    RNRDText(text: "deleteAfterSave")
                        .background(Color.renardDarkBlue)
                        .padding(.vertical, 15.0)
                    Toggle("", isOn: $viewModel.shouldDeleteAfterSave)
                        .frame(width: 100.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.0)
                .background(Color.renardDarkBlue)
                
                HStack{
                    Spacer()
                    Button(action: {
                        print("guardar")
                    }, label: {
                        RNRDText(text: "save")
                            .background(Color.renardMediumBlue)
                            .padding()
                    })
                    .frame(height: 40.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.0)
                .background(Color.renardMediumBlue)
            }
        }
        .background(Color.renardDarkBlue.ignoresSafeArea())
        .toolbarBackground(Color.renardMediumBlue, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                RNRDText(text: "Renard", size: 16)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    @Environment(\.dismiss) var dismiss
                }){
                    Image(systemName:  "multiply")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear{
            viewModel.getImagePreview(asset: asset.asset)
        }
    }
}
