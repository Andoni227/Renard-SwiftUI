import SwiftUI
import Photos
import PhotosUI

struct MainDashboardView: View {
    @StateObject private var viewModel = MainDashboardViewModel()
    @State private var showFAQ = false
    @State private var selectedAsset: AssetObject? = nil
    @State private var photosFromPicker: [PhotosPickerItem] = []
    @State private var openPicker = false
    @Environment(\.scenePhase) private var scenePhase
    let imageManager = PHImageManager.default()
    let options = PHImageRequestOptions()
    var columnsCount: Int {
        max(1, getElementsInScreen(for: 120.0))
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
                    Button(action: {
                        viewModel.isOnSelection = false
                        viewModel.clearSelection()
                        openPicker = true
                    }) {
                        Image(systemName: "photo.badge.magnifyingglass")
                            .renderingMode(.template)
                            .imageScale(.large)
                            .tint(.white)
                    }
                    .photosPicker(isPresented: $openPicker, selection: $photosFromPicker, matching: .images, photoLibrary: .shared())
                    .onChange(of: photosFromPicker) { newItems in
                        Task {
                            await viewModel.convertFromPicker(newItems)
                            photosFromPicker = []
                        }
                    }
                    .buttonStyle(.automatic)
                    .padding()
                    Spacer()
                    Button(viewModel.isOnSelection ? "cancel" : "selectTxt") {
                        withAnimation{
                            viewModel.isOnSelection.toggle()
                        }
                        if !viewModel.isOnSelection {
                            viewModel.cancelConvertion()
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
                .background(Color.renardDarkBlue)

                let rows = [ GridItem() ]
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 10) {
                        ForEach(viewModel.availableFormats, id: \.self) { format in
                            TitleFormatView(imageFormat: format, selectedFormat: $viewModel.selectedFormat)
                        }
                    }
                    .padding(.horizontal, 15)
                    .frame(height: 35)
                }
                .background(Color.renardDarkBlue)
                .padding(.vertical, -8)

                if viewModel.isLoading {
                    Color.renardBackgroundHeavy
                        .frame(height: 100.0)
                        .padding(.top, 22.0)
                    LoadingView(progress: $viewModel.convertionProgress, showLabel: true)
                        .padding()
                    Color.renardBackgroundHeavy
                        .ignoresSafeArea()
                } else {
                    let assets = viewModel.getPhotosForFormat()
                    let rowsOfAssets = assets.chunked(into: columnsCount)
                    List {
                        ForEach(0 ..< rowsOfAssets.count, id: \.self) { rowIndex in
                            HStack(spacing: 10) {
                                ForEach(rowsOfAssets[rowIndex], id: \.asset.localIdentifier) { assetObject in
                                    PhotoThumbnailView(
                                        asset: assetObject.asset,
                                        size: viewModel.imagesSize,
                                        isSelected: viewModel.selectedAssetIDs.contains(assetObject.asset.localIdentifier),
                                        imageManager: self.imageManager,
                                        managerOptions: self.options,
                                        action: {})
                                    .id(assetObject.asset.localIdentifier)
                                    .contentShape(Rectangle())
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                            if viewModel.isOnSelection {
                                                viewModel.toggleSelection(of: assetObject.asset)
                                            } else {
                                                selectedAsset = assetObject
                                            }
                                        }
                                }
                                if rowsOfAssets[rowIndex].count < columnsCount {
                                    ForEach(0 ..< (columnsCount - rowsOfAssets[rowIndex].count), id: \.self) { _ in
                                        Color.clear.frame(maxWidth: .infinity, minHeight: 0)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            .listRowBackground(Color.renardBackgroundHeavy)
                        }
                    }
                    .padding(.top, 10.0)
                    .preferredColorScheme(.dark)
                    .listStyle(.plain)
                    .scrollIndicators(.visible)
                    .scrollContentBackground(.hidden)
                    .background(Color.renardBackgroundHeavy)
                }
            }
            .background(Color.renardBackgroundHeavy)
            .overlay {
                VStack {
                    if viewModel.isOnSelection && viewModel.selectedAssetIDs.count > 0 {
                        MainDashboardBottomView(photoSize: $viewModel.selectedAssetsSize, deleteAfterSave: $viewModel.deleteAfterSave, btnAction: {
                            Task { await viewModel.startConvertion() }
                        }, btnDisabled: viewModel.isLoading)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isOnSelection)
            }
        }
        .sheet(isPresented: $showFAQ) {
            NavigationStack { AboutAppView() }
        }
        .sheet(item: $selectedAsset) { asset in
            NavigationStack { PhotoPreview(asset: asset) }
        }
        .onAppear { viewModel.requestAuthorizationAndLoad() }
        .environmentObject(viewModel)
        .alert("saveSuccess", isPresented: $viewModel.processComplete) {
            Button("accept", role: .cancel) {
                viewModel.clearSelection()
                viewModel.loadPhotos()
                viewModel.cleanCache()
            }
        }
        .alert("camera_permission", isPresented: $viewModel.needsPemission) {
            Button("accept", role: .cancel) { viewModel.openSettings() }
        }
        .alert("requestPermission", isPresented: $viewModel.limitedAccess) {
            Button("openSettings", role: .cancel) {
                viewModel.clearSelection()
                viewModel.loadPhotos()
                viewModel.openSettings()
            }
            Button("accept", role: .destructive) {
                viewModel.clearSelection()
                viewModel.loadPhotos()
                viewModel.limitedAccess = false
            }
        } message: {
            Text("limitedAccessWarning")
        }
        .onChange(of: scenePhase) { scene in
            switch scene{
             case .active: viewModel.requestAuthorizationAndLoad()
             case .background, .inactive: break
             @unknown default: break
            }
        }
    }
}


fileprivate extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [Array(self)] }
        var chunks: [[Element]] = []
        var index = 0
        while index < self.count {
            let end = Swift.min(index + size, self.count)
            chunks.append(Array(self[index..<end]))
            index += size
        }
        return chunks
    }
}

// Preview
#Preview {
    MainDashboardView()
}
