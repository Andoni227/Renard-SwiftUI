//
//  PhotoInfoViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 20/07/25.
//

import Combine
import Photos
import SwiftUICore

class PhotoInfoViewModel: ObservableObject{
    @Published var jsonMetadata: JSON?
    @Published var fileName: String?
    @Published var imageData: PhotosViewData = []
    
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
                        self.setImageData()
                    }
                    return
                }
            }
        }
    }
    
    private func getCameraInfo(_ data: JSON) -> [String] {
        var cameraInfo: [String] = []
        let maker: String? = data.Make
        let model: String? = data.Model
        let software: String? = data.Software
        let dateTime: String? = data.DateTime
        let artist: String? = data.Artist
        let copyright: String? = data.Copyright
        
        if let model = model,  let maker = maker {
            if model.contains(maker){
                cameraInfo.append(model)
            }else{
                cameraInfo.append("\(maker) \(model)")
            }
        }
        
        if let swrtVersion = software{
            if model?.contains("iPhone") ?? false {
                cameraInfo.append("Software: iOS \(swrtVersion)")
            }else{
                cameraInfo.append("Software: \(swrtVersion)")
            }
        }
        
        if let date = dateTime{
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = inputFormatter.date(from: date) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "MMMM dd yyyy, hh:mm a"
                outputFormatter.locale = Locale.current
                
                cameraInfo.append(outputFormatter.string(from: date).capitalized)
            }
        }
        
        if let artist = artist{
            cameraInfo.append("\(NSLocalizedString("artist", comment: "")): \(artist)")
        }
        
        if let rights = copyright{
            cameraInfo.append("Copyright: \(rights)")
        }
        
        return cameraInfo
    }
    
    private func getGPSData(_ data: JSON) -> [String] {
        var gpsInfo: [String] = []
        
        return gpsInfo
    }
    
    func setImageData() {
        let tiff: JSON? = jsonMetadata?.TIFF
        let GPS: JSON? = jsonMetadata?.GPS
        let exifAux: JSON? = jsonMetadata?.ExifAux
        let exif: JSON? = jsonMetadata?.Exif
        
        if let tiffInfo = tiff{
            var cameraInfoSection = PhotoViewData(titleSection: "TIFF")
            cameraInfoSection.elements = getCameraInfo(tiffInfo)
            imageData.append(cameraInfoSection)
        }
        
        if let GPSData = GPS{
            var gpsInformation = PhotoViewData(titleSection: "GPS")
            gpsInformation.elements = getGPSData(GPSData)
            imageData.append(gpsInformation)
            
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: GPSData.data, options: [.prettyPrinted]) {
                print(String(data: jsonData, encoding: .utf8)!) // JSON como texto
            }
            
        }
        
    }
}

typealias PhotosViewData = [PhotoViewData]
struct PhotoViewData: Identifiable {
    var id = UUID()
    var titleSection: LocalizedStringKey
    var titleFooter: LocalizedStringKey? = nil
    var elements: [String] = []
    
    init(titleSection: LocalizedStringKey) {
        self.titleSection = titleSection
    }
}
