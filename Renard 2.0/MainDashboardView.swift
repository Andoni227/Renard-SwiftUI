//
//  ContentView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 21/05/25.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var viewModel = MainDashboardViewModel()
    @State private var showFAQ = false
    
    var galleryColumns: [GridItem] {
        let count = getElementsInScreen(for: 120.0)
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }
    
    var body: some View {
        ZStack{
            Color.renardDarkBlue
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        showFAQ = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .renderingMode(.template)
                            .imageScale(.large)
                            .tint(.white)
                    }
                    .buttonStyle(.automatic)
                    Spacer()
                    Button(viewModel.isOnSelection ? "cancel" : "selectTxt") {
                        viewModel.isOnSelection.toggle()
                        if !viewModel.isOnSelection {
                            viewModel.clearSelection()
                        }
                    }
                    .font(.custom(RenardFont.Medium.rawValue, size: 15.0))
                    .tint(.white)
                }
                .overlay(
                    RNRDText(text: "Renard"),
                    alignment: .center
                )
                .padding()
                
                let rows = [
                    GridItem()
                ]
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 10) {
                        ForEach(viewModel.availableFormats, id: \.self) { format in
                            TitleFormatView(imageFormat: format, selectedFormat: $viewModel.selectedFormat)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    .frame(height: 35)
                }
                .padding(.vertical, -8)
                
                let selectedPhotos = viewModel.photos.filter { $0.format == viewModel.selectedFormat }
                
                GeometryReader { geo in
                    let gridCount = getElementsInScreen(for: 120.0)
                    let totalSpacing = CGFloat((gridCount - 1) * 10)
                    let itemWidth = (geo.size.width - totalSpacing - 20) / CGFloat(gridCount)
                    
                    ScrollView(showsIndicators: true) {
                        LazyVGrid(columns: galleryColumns, spacing: 10) {
                            ForEach(selectedPhotos, id: \.asset.localIdentifier) { assetObject in
                                PhotoThumbnailView(asset: assetObject.asset, size: itemWidth, isSelected: viewModel.selectedAssetIDs.contains(assetObject.asset.localIdentifier))
                                    .onTapGesture {
                                        if viewModel.isOnSelection {
                                            viewModel.toggleSelection(of: assetObject.asset)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .background(Color.renardBackgroundHeavy)
                }
            }
            .overlay{
                if viewModel.isOnSelection{
                    VStack{
                        Spacer()
                        HStack{
                            RNRDText(text: "deleteAfterSave")
                                .background(Color.renardDarkBlue)
                                .padding(.vertical, 15.0)
                            Toggle("", isOn: $viewModel.deleteAfterSave)
                                .frame(width: 100.0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8.0)
                        .background(Color.renardDarkBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showFAQ) {
            NavigationStack {
                AboutAppView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            RNRDText(text: "Renard", size: 16)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(value: Router.preferences) {
                                Image(systemName: "gearshape")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(value: Router.statistics) {
                                Image(systemName:  "chart.bar.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                        }
                    }
            }
        }
        .onAppear {
            viewModel.requestAuthorizationAndLoad()
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    MainDashboardView()
}
