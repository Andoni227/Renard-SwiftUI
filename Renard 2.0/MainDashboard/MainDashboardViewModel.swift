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
    @Published var selectedFormat: ImageType? = nil{
        didSet{
            clearSelection()
        }
    }
    @Published var isOnSelection: Bool = false
    @Published var selectedAssetsSize: String = ""
    @Published var selectedAssetIDs = Set<String>(){
        didSet{
            setImageSize()
        }
    }
    @Published var deleteAfterSave: Bool = false
    @Published var isLoading: Bool = false
    @Published var convertionProgress: Double = 0.0
    @Published var processComplete: Bool = false
    
    private var photosMap: [String: AssetObject] = [:]
    
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
    
    @MainActor
    func startConvertion() async {
        self.isLoading = true
        
        var selectedAssets: [PHAsset] = []
        
        for id in selectedAssetIDs{
            if let asset = self.photosMap[id]?.asset{
                selectedAssets.append(asset)
            }
        }
        
        let results = await ImageConverter().convertAndSaveAssetsAsHEIF(from: selectedAssets, progressHandler: { progress in
            self.convertionProgress = progress
        })
        
        print("SUCCESS \(results.filter({ $0.0 == true }).count) ERRORS \(results.filter({ $0.0 == false }).count)")
        print("ERRORES: \(results.map({ $0.1 }))")
        
        finishProcess()
    }
    
    func finishProcess(){
        DispatchQueue.main.async { [self] in
            isLoading = false
            isOnSelection = false
            if deleteAfterSave{
                self.deleteAsset(identifiers: Array(selectedAssetIDs), completion: { success, error in
                    DispatchQueue.main.async {
                        self.processComplete = true
                    }
                })
            }else{
                processComplete = true
            }
        }
    }
    
    func loadPhotos() {
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
            self.photosMap = Dictionary(uniqueKeysWithValues: tempPhotos.map { ($0.asset.localIdentifier, $0) })
            self.availableFormats = formatsCount.sorted(by: { $0.count > $1.count })
            self.selectedFormat = self.availableFormats.first?.imageType ?? nil
        }
    }
    
    private func setImageSize() {
        let ids = Array(selectedAssetIDs)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var total: Int64 = 0
            for id in ids {
                if let assetObj = self.photosMap[id] {
                    total += Int64(assetObj.asset.getSize(format: .raw)) ?? 0
                }
            }
            let readable = total.bytesToReadableSize()
            DispatchQueue.main.async {
                self.selectedAssetsSize = readable
            }
        }
    }
}
