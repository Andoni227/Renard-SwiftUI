//
//  PhotoInfoViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 20/07/25.
//

import Combine
import Photos

class PhotoInfoViewModel: ObservableObject{
    @Published var jsonMetadata: JSON?
    @Published var fileName: String?
    @Published var camera: String?
    
    func getAssetMetadata(asset: PHAsset) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        
        let resources = PHAssetResource.assetResources(for: asset)
        self.fileName = resources.first?.originalFilename
        
        asset.requestContentEditingInput(with: options) { [self] contentEditingInput, _ in
            guard let input = contentEditingInput else {
                return
            }
            if let fullSizeImageURL = input.fullSizeImageURL {
                if let imageSource = CGImageSourceCreateWithURL(fullSizeImageURL as CFURL, nil) {
                    let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any]
                    if let jsonData = metadata{
                        self.jsonMetadata = JSON(data: jsonData)
                        setData()
                    }
                    return
                }
            }
        }
    }
    
    func setData() {
        let tiff: JSON? = jsonMetadata?.TIFF
        let makerApple: JSON? = jsonMetadata?.MakerApple
        let GPS: JSON? = jsonMetadata?.GPS
        let exifAux: JSON? = jsonMetadata?.ExifAux
        let exif: JSON? = jsonMetadata?.Exif
        
        self.camera = tiff?.Model
    }
}



@dynamicMemberLookup
struct JSON {
    let data: [String: Any]
    
    subscript<T>(dynamicMember member: String) -> T? {
        let key: String
        if member == "TIFF" || member == "GPS" || member == "Exif" || member == "MakerApple" || member == "ExifAux"{
          key = "{\(member)}"
        }else{
            key = member
        }
        
        let value = data[key]
        if let nestedDict = value as? [String: Any]{
            return JSON(data: nestedDict) as? T
        }else{
            return value as? T
        }
    }
}
