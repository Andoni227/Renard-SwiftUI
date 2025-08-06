//
//  MediaExtensions.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 22/05/25.
//

import Photos


extension PHAsset{
    func getResolution() -> Int{
        let width = Double(self.pixelWidth)
        let height = Double(self.pixelHeight)
        
        let resolution = Int((width * height / 1000000).rounded())
        
        return resolution
    }
    
    func getType() -> ImageType{
        guard self.mediaType == .image else {
            return .NOTIMAGE
        }
        
        guard let uniformType = self.value(forKey: "uniformTypeIdentifier") as? String else {
            return .UNOWNED
        }
        
        if let imageType = ImageType(rawValue: uniformType) {
            return imageType
        } else {
            return .UNOWNED
        }
    }
}
