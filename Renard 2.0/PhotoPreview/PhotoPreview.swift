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
    @EnvironmentObject var dashboardVM: MainDashboardViewModel
    
    let asset: AssetObject
    
    var body: some View {
        ZStack{
            Color.renardBackgroundHeavy
                .padding(.top, -30)
            
            if viewModel.isLoading{
                LoadingView(progress: $viewModel.downloadProgress)
                    .padding(.bottom, 100.0)
            }else{
                if let img = viewModel.imgPreview{
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 100.0)
                }
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
                        viewModel.convertImage(asset: asset.asset)
                    }, label: {
                        RNRDText(text: "save")
                            .background(Color.renardMediumBlue)
                            .padding()
                    })
                    .disabled(viewModel.isLoading)
                    .frame(height: 40.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.0)
                .background(Color.renardMediumBlue)
            }
        }
        .alert("saveSuccess", isPresented: $viewModel.processComplete) {
            Button("accept", role: .cancel) {
                dismiss()
                dashboardVM.loadPhotos()
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
                    dismiss()
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
