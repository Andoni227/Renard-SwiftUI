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
            return .VIDEO
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
    
    func getFileName() -> String?{
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first(where: { $0.type == .photo }) {
                return resource.originalFilename
            }
            return resources.first?.originalFilename
        }
        return value(forKey: "filename") as? String
    }

    func getExifDate(for asset: PHAsset) async -> Date? {
        await withCheckedContinuation { continuation in
            
            guard let resource = PHAssetResource.assetResources(for: asset).first else {
                continuation.resume(returning: nil)
                return
            }
            
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
            
            PHAssetResourceManager.default().writeData(for: resource, toFile: tempURL, options: options) { error in
                
                guard error == nil else {
                    continuation.resume(returning: nil)
                    return
                }
                
                guard
                    let source = CGImageSourceCreateWithURL(tempURL as CFURL, nil),
                    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
                    let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
                    let dateString = exif[kCGImagePropertyExifDateTimeDigitized] as? String
                else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let formatter = DateFormatter()
                var dateFormatt = "yyyy:MM:dd HH:mm:ss"
                
                if let exifTimeZone = exif[kCGImagePropertyExifOffsetTimeDigitized] as? String {
                    dateFormatt = "\(dateFormatt)\(exifTimeZone)"
                }
                
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = dateFormatt
                
                continuation.resume(returning: formatter.date(from: dateString))
            }
        }
    }
}
