//
//  MainDashboardViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 22/05/25.
//

import SwiftUI
import Photos

class MainDashboardViewModel: ObservableObject {
    @Published var photos: [AssetObject] = []
    @Published var availableFormats: [FormatObject] = []
    @Published var selectedFormat: ImageType? = nil
    @Published var isOnSelection: Bool = false
    @Published var selectedAssetIDs = Set<String>() 
    
    init() { }
    
    func clearSelection() {
        selectedAssetIDs.removeAll()
    }
    
    func requestAuthorizationAndLoad() {
        guard photos.isEmpty else { return }
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else { return }
                self.loadPhotos()
            }
        }
    }
    
    func toggleSelection(of asset: PHAsset) {
        let id = asset.localIdentifier
        if selectedAssetIDs.contains(id) {
            selectedAssetIDs.remove(id)
        } else {
            selectedAssetIDs.insert(id)
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var tempPhotos: [AssetObject] = []
        var formatCountDict: [ImageType: Int] = [:]
        
        fetchResult.enumerateObjects { (asset, _, _) in
            let type = asset.getType()
            let resolution = asset.getResolution()
            tempPhotos.append(AssetObject(asset: asset, format: type, resolution: resolution))
            formatCountDict[type, default: 0] += 1
        }
    
        let formatsCount = formatCountDict.map { FormatObject(id: UUID(), imageType: $0.key, count: $0.value) }

        DispatchQueue.main.async {
            self.photos = tempPhotos
            self.availableFormats = formatsCount.sorted(by: { $0.count > $1.count })
            self.selectedFormat = self.availableFormats.first?.imageType ?? nil
        }
    }
}
