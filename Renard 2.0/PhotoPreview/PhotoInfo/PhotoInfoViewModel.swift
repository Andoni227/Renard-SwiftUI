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
        imageData = []
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
    
    private func dateConvertion(_ date: String) -> String?{
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMMM dd yyyy, hh:mm:ss a"
            outputFormatter.locale = Locale.current
            
            return outputFormatter.string(from: date).capitalized
        }else {
            return nil
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
        
        if let date = dateTime, let dateFormatted = dateConvertion(date){
            cameraInfo.append(dateFormatted)
        }
        
        if let artist = artist{
            cameraInfo.append("\(NSLocalizedString("artist", tableName: "AuxLocales", comment: "")): \(artist)")
        }
        
        if let rights = copyright{
            cameraInfo.append("Copyright: \(rights)")
        }
        
        return cameraInfo
    }
    
    private func getGPSData(_ data: JSON) -> [String] {
        var gpsInfo: [String] = []
        let latitude: Double? = data.Latitude
        let longitude: Double? = data.Longitude
        let altitude: Double? = data.Altitude
        let speed: Double? = data.Speed
        let speedRef: String? = data.SpeedRef
        let gpsStatus: String? = data.Status
        let gpsDate: String? = data.DateStamp
        let gpsTime: String? = data.TimeStamp
        
        if let imgLatitude = latitude{
            gpsInfo.append("\(NSLocalizedString("latitude", tableName: "AuxLocales", comment: "")): \(imgLatitude)")
        }
        
        if let imgLongitude = longitude{
            gpsInfo.append("\(NSLocalizedString("longitude", tableName: "AuxLocales", comment: "")): \(imgLongitude)")
        }
        
        if let imgAltitude = altitude{
            gpsInfo.append("\(NSLocalizedString("altitude", tableName: "AuxLocales", comment: "")): \(imgAltitude.rounded())")
        }
        
        if let imgSpeed = speed, let imgSpeedUnit = speedRef{
            let photoSpeed = "\(NSLocalizedString("speed", tableName: "AuxLocales", comment: "")): \(imgSpeed.rounded())"
            var photoSpeedUnit = imgSpeedUnit
            switch imgSpeedUnit {
              case "K": photoSpeedUnit = "km/h"
              case "M": photoSpeedUnit = "mph"
              case "N": photoSpeedUnit = NSLocalizedString("speed_knot", tableName: "AuxLocales", comment: "")
              default: ()
            }
            
            gpsInfo.append("\(photoSpeed) \(photoSpeedUnit)")
        }
        
        if var imgGPSStatus = gpsStatus, imgGPSStatus == "V"{
            imgGPSStatus = NSLocalizedString("gps_void", tableName: "AuxLocales", comment: "")
            gpsInfo.append(imgGPSStatus)
        }
        
        if let gpsDate = gpsDate, let gpsTime = gpsTime, let dateConverted = dateConvertion("\(gpsDate) \(gpsTime)"){
            gpsInfo.append("\(dateConverted) (UTC)")
        }
        
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
