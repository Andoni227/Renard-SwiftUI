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
    @Published var downloadProgress: Int = 0
    
    init() {
        self.shouldDeleteAfterSave = UserDefaults.standard.bool(forKey: "deleteAfterSave")
        
    }
    
    func getImagePreview(asset: PHAsset){
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
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
                }
            }
        }
    }
}


