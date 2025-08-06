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
        List {
            ForEach(viewModel.imageData, content: { section in
                Section {
                    ForEach(section.elements, id: \.self) { text in
                        RNRDText(text: LocalizedStringKey(text), size: 15.0)
                            .listRowBackground(Color.renardMediumBlue)
                    }
                } header: {
                    RNRDText(text: section.titleSection, size: 15.0)
                } footer: {
                    RNRDText(text: section.titleFooter ?? "", size: 15.0)
                }
            })
        }
        .scrollContentBackground(.hidden)
        .listStyle(.automatic)
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
