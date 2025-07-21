//
//  PhotoInfoView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 20/07/25.
//

import SwiftUI
import Photos

struct PhotoInfoView: View {
    @StateObject private var viewModel = PhotoInfoViewModel()
    let asset: AssetObject

    var body: some View {
        
        HStack{
            VStack(alignment: .leading){
                RNRDText(text: "Title", size: 30.0)
                    .padding(.bottom, 10.0)
                RNRDText(text: "\(viewModel.fileName ?? "Unknown")")
                    .padding(.bottom, 10.0)
                RNRDText(text: "Camera", size: 30.0)
                    .padding(.bottom, 10.0)
                RNRDText(text: "\(viewModel.camera ?? "Unknown")")
                Spacer()
            }
            .padding(.horizontal, 10.0)
            Spacer()
        }
        
        .background(Color.renardDarkBlue.ignoresSafeArea())
        .toolbarBackground(Color.renardMediumBlue, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear{
            viewModel.getAssetMetadata(asset: asset.asset)
        }
    }
}

#Preview {
    PhotoInfoView(asset: AssetObject(asset: PHAsset(), format: .ARW, resolution: 10))
}
