//
//  VideoSettingds.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 07/11/25.
//

import SwiftUI

struct VideoSettings: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VideoSettingsViewModel()
    
    var body: some View {
        ZStack{
            Color.renardDarkBlue.ignoresSafeArea()
            VStack(alignment: .leading){
                HStack{
                    Button(action: {
                        viewModel.showCodecs = true
                    }, label: {
                        Text("videoCodec")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Text(viewModel.getVideoCodecName())
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    })
                    .background(Color.renardDarkBlue)
                }
                HStack{
                    Button(action: {
                        viewModel.showPresets = true
                    }, label: {
                        Text("Preset")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Text(viewModel.getVideoPresetName())
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    })
                    .background(Color.renardDarkBlue)
                }
                HStack{
                    Button(action: {
                        viewModel.showFormats = true
                    }, label: {
                        Text("Format")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Text(viewModel.getVideoFormatName())
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                    })
                    .background(Color.renardDarkBlue)
                }
                Spacer()
            }
        }
        .toolbarBackground(Color.renardDarkBlue, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(LocalizedStringKey("ExportOptions"))
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
        .confirmationDialog("Codec", isPresented: $viewModel.showCodecs, actions: viewModel.getCodecOptions)
        .confirmationDialog("Preset", isPresented: $viewModel.showPresets, actions: viewModel.getPresetOptions)
        .confirmationDialog("Format", isPresented: $viewModel.showFormats, actions: viewModel.getFormatOptions)
    }
}
