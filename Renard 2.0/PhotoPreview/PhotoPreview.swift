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
                LoadingView(progress: $viewModel.downloadProgress, progressTitle: $viewModel.downloadText, showLabel: false)
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
                if asset.format != .VIDEO{
                    HStack{
                        RNRDText(text: "delete_after_save")
                            .background(Color.renardDarkBlue)
                            .padding(.vertical, 15.0)
                        Toggle("", isOn: $viewModel.shouldDeleteAfterSave)
                            .frame(width: 100.0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8.0)
                    .background(Color.renardDarkBlue)
                }
                HStack{
                    if asset.format == .VIDEO && viewModel.isLoading{
                        Button(action: {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .cancelExportNotification, object: nil)
                            }
                        }, label: {
                            RNRDText(text: "cancel")
                                .background(Color.renardMediumBlue)
                                .padding()
                        })
                        .frame(height: 40.0)
                    }
                    Spacer()
                    Button(action: {
                        viewModel.startConvertion(asset: asset.asset)
                    }, label: {
                        RNRDText(text: viewModel.getSaveTitle(format: asset.format))
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
        .sheet(isPresented: $viewModel.videoExportComplete) {
            if let video = viewModel.finalExport {
                ShareUtility(items: [video])
            }
        }
        .alert("saveSuccess", isPresented: $viewModel.photoExportComplete) {
            Button("accept", role: .cancel) {
                dismiss()
                dashboardVM.loadPhotos()
            }
        }
        .background(Color.renardDarkBlue.ignoresSafeArea())
        .toolbarBackground(Color.renardMediumBlue, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                RNRDText(text: "Renard", size: 16)
            }
            if asset.format == .VIDEO {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: Router.videoSettings) {
                        Image(systemName:  "gearshape")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
            }else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(value: Router.photoInfo(asset: asset)) {
                        Image(systemName:  "info.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    NotificationCenter.default.post(name: .cancelExportNotification, object: nil)
                    dismiss()
                }){
                    Image(systemName:  "multiply")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationDestination(for: Router.self, destination: { router in router.view })
        .onAppear{
            viewModel.getImagePreview(asset: asset.asset)
        }
    }
}
