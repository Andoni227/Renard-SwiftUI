//
//  MainDashboardViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 22/05/25.
//

import SwiftUI
import Photos
import PhotosUI

class MainDashboardViewModel: ObservableObject {
    @Published var photos: [AssetObject] = []
    @Published var availableFormats: [FormatObject] = []
    @Published var selectedFormat: ImageType? = nil{
        didSet{
            enableSelection = selectedFormat != .VIDEO
            isOnSelection = false
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
    @Published var convertionProgressTitle: LocalizedStringKey = "loading"
    @Published var processComplete: Bool = false
    @Published var imagesSize: Double = 0.0
    @Published var needsPemission: Bool = false
    @Published var limitedAccess: Bool = false
    @Published var fixDateAlert: Bool = false
    @Published var fixedDatesComplete: Bool = false
    @Published var enableSelection: Bool = false
    @Published var videoExportComplete: Bool = false
    @Published var finalExport: URL?
    
    var emptyElements: Bool = false
    private var photosMap: [String: AssetObject] = [:]
    private var convertionTask: Task<Void, Never>?
    
    init() { }
    
    func setSize() {
        func getElementsInScreen(for size: CGFloat) -> Int{
            return Int(UIScreen.main.bounds.width / size)
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let gridCount = getElementsInScreen(for: 120.0)
        let totalSpacing = CGFloat((gridCount - 1) * 10)
        imagesSize = (screenWidth - totalSpacing - 20) / CGFloat(gridCount)
    }
    
    func clearSelection() {
        selectedAssetIDs.removeAll()
    }
    
    func requestAuthorizationAndLoad() {
        setSize()
        guard photos.isEmpty else {
            loadPhotos()
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    self.needsPemission = true
                    return
                }
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
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func finishProcess() {
        DispatchQueue.main.async { [self] in
            isLoading = false
            isOnSelection = false
            if deleteAfterSave{
                self.deleteAsset(identifiers: Array(selectedAssetIDs), completion: { success, error in
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                })
            }else{
                showAlert()
            }
        }
    }
    
    func showAlert() {
        if self.emptyElements {
            self.limitedAccess = true
        } else {
            self.processComplete = true
            
        }
    }
    
    func loadPhotos() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            
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
    }
    
    func cleanCache() {
        AppCleaner().clearTemporalDirectory()
    }
    
    func getSearchIcon() -> String {
        return selectedFormat == .VIDEO ? "folder" : "photo.badge.magnifyingglass"
    }
    
    func getPhotoDates() async -> [String:Date] {
        var selectedAssets: [PHAsset] = []
        var assetsDates: [String: Date] = [:]
        for id in selectedAssetIDs{
            if let asset = self.photosMap[id]?.asset{
                selectedAssets.append(asset)
            }
        }
        
        for asset in selectedAssets {
            if let newDate = await asset.getExifDate(for: asset) {
                assetsDates[asset.localIdentifier] = newDate
            } else {
                assetsDates[asset.localIdentifier] = asset.creationDate
            }
        }
        
        return assetsDates
    }
    
    func startDateRepair(completion : @escaping (Bool, Error?) -> Void ) async {
        var selectedAssets: [PHAsset] = []
        let assetsDates = await getPhotoDates()
        for id in selectedAssetIDs{
            if let asset = self.photosMap[id]?.asset{
                selectedAssets.append(asset)
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            for asset in selectedAssets {
                let photoDate = assetsDates[asset.localIdentifier] ?? asset.creationDate
                let request = PHAssetChangeRequest(for: asset)
                request.creationDate = photoDate
            }
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    @MainActor
    func getVideoFromPicker(video: URL?) async {
        guard let url = video else { return }
        self.isLoading = true
        
        AppCleaner().clearTemporalDirectory()
        
        await FileProvider().accessSecurityScopedResource(from: url) { safeURL, pathName, fileName  in
            do {
                let data = try Data(contentsOf: safeURL)
                let tmp = FileManager.default.temporaryDirectory
                    .appendingPathComponent("temp.mp4")
                
                try data.write(to: tmp)
                
                let asset = AVAsset(url: tmp)
                VideoConverter.shared.exportVideoFrom(asset: asset, fileName: fileName, completion: { url, error in
                    DispatchQueue.main.async { [self] in
                        isLoading = false
                        
                        if let url = url {
                            finalExport = url
                            videoExportComplete = true
                        }
                    }
                }, exportProgressHandler: { progress in
                    DispatchQueue.main.async { [self] in
                        convertionProgress = progress
                        let progressDouble = Int((progress * 100).rounded())
                        convertionProgressTitle = "exportingVideo \(progressDouble)%"
                    }
                })
            } catch {
                print("Error al copiar el archivo:", error)
            }
        }
    }
    
    @MainActor
    func startConvertion() async {
        self.isLoading = true
        self.convertionProgress = 0
        self.convertionProgressTitle = "loading"
        var selectedAssets: [PHAsset] = []
        
        for id in selectedAssetIDs{
            if let asset = self.photosMap[id]?.asset{
                selectedAssets.append(asset)
            }else{
                emptyElements = true
            }
        }
        
        convertionTask = Task {
            do {
                let results = try await ImageConverter().convertAndSaveAssetsAsHEIF(from: selectedAssets) { progress in
                    self.convertionProgress = progress
                }
                print("SUCCESS \(results.filter({ $0.0 == true }).count) ERRORS \(results.filter({ $0.0 == false }).count)")
                print("ERRORES: \(results.map({ $0.1 }))")
                finishProcess()
            } catch is CancellationError {
                print("Proceso cancelado")
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func cancelConvertion() {
        self.isLoading = false
        self.isOnSelection = false
        self.convertionProgress = 0
        NotificationCenter.default.post(name: .cancelExportNotification, object: nil)
        guard let convertionTask else { return }
        convertionTask.cancel()
        self.loadPhotos()
    }
    
    @MainActor
    func getPhotosForFormat() -> [AssetObject] {
        let photosForFormat = photos.filter { $0.format == selectedFormat }
        return Array(photosForFormat)
    }
    
    @MainActor
    func convertFromPicker(_ photos: [PhotosPickerItem]) async {
        self.selectedAssetIDs.removeAll()
        for item in photos{
            if let imgId = item.itemIdentifier{
                self.selectedAssetIDs.insert(imgId)
            }
        }
        await startConvertion()
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
