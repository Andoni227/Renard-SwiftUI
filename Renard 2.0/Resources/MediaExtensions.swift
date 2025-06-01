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
            print("El PHAsset no es un archivo de imagen")
            return .NOTIMAGE
        }
        
        guard let uniformType = self.value(forKey: "uniformTypeIdentifier") as? String else {
            print("No se pudo obtener el uniformTypeIdentifier del PHAsset")
            return .UNOWNED
        }
        
        if let imageType = ImageType(rawValue: uniformType) {
            return imageType
        } else {
            return .UNOWNED
        }
    }
}
