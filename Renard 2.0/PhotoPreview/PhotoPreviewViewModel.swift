//
//  PhotoPreviewViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 04/06/25.
//

import SwiftUI
import Photos
import Lottie

class PhotoPreviewViewModel: ObservableObject{
    @Published var shouldDeleteAfterSave: Bool {
        didSet {
            UserDefaults.standard.set(shouldDeleteAfterSave, forKey: "deleteAfterSave")
        }
    }
    @Published var imgPreview: UIImage?
    @Published var lottieCat: LottieAnimation?
    @Published var downloadProgress: Double = 0
    @Published var downloadText: LocalizedStringKey = ""
    @Published var isLoading: Bool = true
    @Published var photoExportComplete: Bool = false
    @Published var videoExportComplete: Bool = false
    @Published var finalExport: URL?
    
    init() {
        self.shouldDeleteAfterSave = UserDefaults.standard.bool(forKey: "deleteAfterSave")
    }
    
    func getImagePreview(asset: PHAsset){
        guard imgPreview == nil else { return }
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, error, pointer, anyHashable in
            
            DispatchQueue.main.async{
                self.downloadProgress = progress
            }
            print("Progreso de descarga: \(progress)")
        }
        
        manager.requestImage(for: asset,
                             targetSize: PHImageManagerMaximumSize,
                             contentMode: .aspectFill,
                             options: options) { result, info in
            
            if let result = result,
               let info = info,
               info[PHImageResultIsInCloudKey] as? Bool != true,
               info[PHImageCancelledKey] as? Bool != true,
               info[PHImageErrorKey] == nil {
                DispatchQueue.main.async {
                    self.imgPreview = result
                    self.isLoading = false
                }
            }
        }
    }
    
    func startConvertion(asset: PHAsset){
        self.isLoading = true
        
        if asset.mediaType == .video {
            DispatchQueue.global(qos: .userInitiated).async {
                VideoConverter.shared.export(asset, completion: { url, error in
                    DispatchQueue.main.async{ [self] in
                       guard let url = url else {
                            print("Error al exportar \(error.debugDescription)")
                            isLoading = false
                            return
                        }
                        isLoading = false
                        finalExport = url
                        videoExportComplete = true
                    }
                }, downloadProgressHandler: { progress in
                    DispatchQueue.main.async{
                        self.downloadProgress = progress
                        let progressDouble = Int((progress * 100).rounded())
                        self.downloadText = "downloadingFromIcloud \(progressDouble)%"
                    }
                }, exportProgressHandler: { progress in
                    DispatchQueue.main.async{
                        self.downloadProgress = progress
                        let progressDouble = Int((progress * 100).rounded())
                        self.downloadText = "exportingVideo \(progressDouble)%"
                    }
                })
            }
        }else{
            DispatchQueue.global(qos: .userInitiated).async {
                ImageConverter().convertAndSaveAssetAsHEIF(from: asset, completion: { success, error in
                    if self.shouldDeleteAfterSave{
                        self.deleteAsset(identifiers: [asset.localIdentifier], completion: { success, error in
                            self.finishPhotoConvertion()
                        })
                    }else{
                        self.finishPhotoConvertion()
                    }
                })
            }
        }
    }
    
    func getSaveTitle(format: ImageType) -> LocalizedStringKey{
        return format == .VIDEO ? "export" : "save"
    }
    
    private func finishPhotoConvertion(){
        DispatchQueue.main.async {
            self.isLoading = false
            self.photoExportComplete = true
        }
    }
}


