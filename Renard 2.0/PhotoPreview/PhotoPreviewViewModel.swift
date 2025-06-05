//
//  PhotoPreviewViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 04/06/25.
//

import SwiftUI
import Photos

class PhotoPreviewViewModel: ObservableObject{
    @Published var shouldDeleteAfterSave: Bool {
        didSet {
            UserDefaults.standard.set(shouldDeleteAfterSave, forKey: "deleteAfterSave")
        }
    }
    @Published var imgPreview: UIImage = UIImage()
    
    init() {
        self.shouldDeleteAfterSave = UserDefaults.standard.bool(forKey: "deleteAfterSave")
    }
    
    func getImagePreview(asset: PHAsset){
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let size = CGSize(width: 200, height: 230)
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            if let result = result {
                self.imgPreview = result
            }
        }
    }
}


