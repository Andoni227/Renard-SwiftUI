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
    @Environment(\.dismiss) var dismiss
    let asset: AssetObject
    
    var body: some View {
        List {
            ForEach(viewModel.imageData, content: { section in
                Section {
                    ForEach(section.elements, id: \.self) { text in
                        if text.contains("MAP_SHOW"){
                            if #available(iOS 17.0, *) {
                                MapView(location: viewModel.imgLocation)
                                    .frame(height: 200.0)
                            }
                        }else{
                            RNRDText(text: LocalizedStringKey(text), size: 15.0)
                                .listRowBackground(Color.renardMediumBlue)
                        }
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
                Text(LocalizedStringKey(viewModel.fileName ?? ""))
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
        .onAppear{
            viewModel.getAssetMetadata(asset: asset.asset)
        }
    }
}

#Preview {
    PhotoInfoView(asset: AssetObject(asset: PHAsset(), format: .ARW, resolution: 10))
}
