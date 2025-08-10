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
    
    private var imageSize: String?
    
    func getAssetMetadata(asset: PHAsset) {
        imageData = []
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        
        let resources = PHAssetResource.assetResources(for: asset)
        self.fileName = resources.first?.originalFilename
        
        imageSize = asset.getSize()
        
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
    
    private func getFlashDescription(of value: Int) -> String{
        switch value {
        case 0:
            return NSLocalizedString("flash_off", tableName: "AuxLocales", comment: "")
        case 1:
            return NSLocalizedString("flash_on", tableName: "AuxLocales", comment: "")
        case 5:
            return NSLocalizedString("flash_on_no_return", tableName: "AuxLocales", comment: "")
        case 7:
            return NSLocalizedString("flash_on_return_not_detected", tableName: "AuxLocales", comment: "")
        case 9:
            return NSLocalizedString("flash_on_auto", tableName: "AuxLocales", comment: "")
        case 16:
            return NSLocalizedString("flash_off_auto", tableName: "AuxLocales", comment: "")
        case 24:
            return NSLocalizedString("flash_off_auto_unavailable", tableName: "AuxLocales", comment: "")
        case 25:
            return NSLocalizedString("flash_on_auto_unavailable", tableName: "AuxLocales", comment: "")
        case 32:
            return NSLocalizedString("flash_off_suppressed", tableName: "AuxLocales", comment: "")
        case 65:
            return NSLocalizedString("flash_on_red_eye", tableName: "AuxLocales", comment: "")
        case 73:
            return NSLocalizedString("flash_on_auto_red_eye", tableName: "AuxLocales", comment: "")
        case 77:
            return NSLocalizedString("flash_on_auto_red_eye_return", tableName: "AuxLocales", comment: "")
        default:
            return NSLocalizedString("flash_unknown", tableName: "AuxLocales", comment: "")
        }
    }
    
    private func getMeteringModeDescription(of value: Int) -> String{
        switch value {
        case 1:
            return NSLocalizedString("metering_mode_average", tableName: "AuxLocales", comment: "")
        case 2:
            return NSLocalizedString("metering_mode_matrix", tableName: "AuxLocales", comment: "")
        case 3:
            return NSLocalizedString("metering_mode_spot", tableName: "AuxLocales", comment: "")
        case 4:
            return NSLocalizedString("metering_mode_center_weighted", tableName: "AuxLocales", comment: "")
        case 5:
            return NSLocalizedString("metering_mode_partial", tableName: "AuxLocales", comment: "")
        case 0:
            fallthrough
        default:
            return NSLocalizedString("metering_mode_unknown", tableName: "AuxLocales", comment: "")
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
    
    private func getExposureTime(of value: Decimal) -> String{
        let division = Decimal(1)/abs(value)
        let rounded = NSDecimalNumber(decimal: division).rounding(accordingToBehavior: nil)
        return rounded == 0 ? "1":"1/\(rounded)"
    }
    
    private func getCameraInfo(_ data: JSON) -> [String] {
        var cameraInfo: [String] = []
        let maker: String? = data.Make
        let model: String? = data.Model
        let software: String? = data.Software
        let dateTime: String? = data.DateTime
        let artist: String? = data.Artist
        let copyright: String? = data.Copyright
        
        if let maker = maker {
            if let model = model{
                if model.contains(maker){
                    cameraInfo.append(model)
                }else{
                    cameraInfo.append("\(maker) \(model)")
                }
            }else{
                cameraInfo.append(maker)
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
    
    private func getEXIFData(_ data: JSON) -> [String] {
        var exifInfo: [String] = []
        let exifDateTime: String? = data.DateTimeOriginal
        let exifFocalLength: Int? = data.FocalLength
        let exifFocal35m: Int? = data.FocalLenIn35mmFilm
        let exifFNumber: Double? = data.FNumber
        let exifExposureTime: Double? = data.ExposureTime
        let exifISOSpeed: [Int]? = data.ISOSpeedRatings
        let exifBrightness: Double? = data.BrightnessValue
        let exifColorSpace: Int? = data.ColorSpace
        let exifFlash: Int? = data.Flash
        let exifWhiteBalance: Int? = data.WhiteBalance
        let exifMeteringMode: Int? = data.MeteringMode
        let exifLensMake: String? = data.LensMake
        let exifLensModel: String? = data.LensModel
        
        if let exifDate = exifDateTime, let dateConverted = dateConvertion("\(exifDate)"){
            exifInfo.append("\(dateConverted)")
        }
        
        if let imgAperture = exifFNumber, let imgShutterSpeed = exifExposureTime,
           let photoISOArray = exifISOSpeed, let photoISO = photoISOArray[safe: 0]{
            exifInfo.append("ƒ/\(String(format: "%.1f", imgAperture)) - ISO: \(photoISO) - \(getExposureTime(of: Decimal(imgShutterSpeed))) s")
        }
        
        if let imgFocalLength = exifFocalLength{
            exifInfo.append("\(NSLocalizedString("focal_lenght", tableName: "AuxLocales", comment: "")): \(imgFocalLength) mm")
        }
        
        if let imgFocal35mm = exifFocal35m{
            exifInfo.append("\(NSLocalizedString("focal_35mm", tableName: "AuxLocales", comment: "")): \(imgFocal35mm) mm")
        }
        
        if let photoEV = exifBrightness{
            exifInfo.append("\(String(format: "%.1f", photoEV)) EV")
        }
        
        if let photoColorProfile = exifColorSpace{
            if photoColorProfile == 1{
                exifInfo.append("\(NSLocalizedString("color_space", tableName: "AuxLocales", comment: "")): sRGB")
            }else{
                exifInfo.append("\(NSLocalizedString("color_space", tableName: "AuxLocales", comment: "")): \(photoColorProfile)")
            }
        }
        
        if let photoFlash = exifFlash{
            exifInfo.append(getFlashDescription(of: photoFlash))
        }
        
        if let photoWhiteBalance = exifWhiteBalance{
            var whiteBalance = ""
            switch photoWhiteBalance {
            case 0:
                whiteBalance = NSLocalizedString("white_balance_auto", tableName: "AuxLocales", comment: "")
            case 1:
                whiteBalance = NSLocalizedString("white_balance_manual", tableName: "AuxLocales", comment: "")
            default:
                whiteBalance = NSLocalizedString("white_balance_unknown", tableName: "AuxLocales", comment: "")
            }
            exifInfo.append(whiteBalance)
        }
        
        if let photoMeteringMode = exifMeteringMode{
            exifInfo.append(getMeteringModeDescription(of: photoMeteringMode))
        }
        
        if let photoLensModel = exifLensModel{
            if let photoLensMake = exifLensMake{
                exifInfo.append("\(photoLensMake) \(photoLensModel)")
            }else{
                exifInfo.append("\(photoLensModel)")
            }
        }
        
        return exifInfo
    }
    
    private func getExifAuxData(_ data: JSON) -> [String] {
        var exifAuxInfo: [String] = []
        let exifAuxFirmware: String? = data.Firmware
        let exifAuxSN: String? = data.SerialNumber
        let exifAuxEstabilization: Int? = data.ImageStabilization
        let exifAuxLensID: Int? = data.LensID
        
        if let cameraFirmware = exifAuxFirmware{
            exifAuxInfo.append(cameraFirmware)
        }
        
        if let cameraSN = exifAuxSN{
            exifAuxInfo.append("SN: \(cameraSN)")
        }
        
        if let cameraStabilization = exifAuxEstabilization{
            switch cameraStabilization {
            case 1:
                exifAuxInfo.append(NSLocalizedString("image_stabilization_on", tableName: "AuxLocales", comment: ""))
            case 2:
                exifAuxInfo.append(NSLocalizedString("image_stabilization_digital", tableName: "AuxLocales", comment: ""))
            case 3:
                exifAuxInfo.append(NSLocalizedString("image_stabilization_optical_digital", tableName: "AuxLocales", comment: ""))
            case 0:
                exifAuxInfo.append(NSLocalizedString("image_stabilization_off", tableName: "AuxLocales", comment: ""))
            default: ()
            }
        }
        
        if let cameraLensID = exifAuxLensID{
            exifAuxInfo.append("LensID: \(cameraLensID)")
        }
        
        return exifAuxInfo
    }
    
    private func setFileProperties() {
        var fileSection = PhotoViewData(titleSection: "file")
        var fileElements: [String] = []
        let imgProfile: String? = jsonMetadata?.ProfileName
        let imgXdimension: Int? = jsonMetadata?.PixelWidth
        let imgYdimension: Int? = jsonMetadata?.PixelHeight
        
        
        if let imgSize = imageSize{
            fileElements.append("\(NSLocalizedString("image_size", tableName: "AuxLocales", comment: "")): \(imgSize)")
        }
        
        if let xDimension = imgXdimension, let yDimension = imgYdimension{
            
            let width = Double(xDimension)
            let height = Double(yDimension)
            let resolution = Double((width * height / Double(1000000)))
            let resolutionString =  String(format: "%.1f", resolution)
            
            fileElements.append("\(NSLocalizedString("image_resolution", tableName: "AuxLocales", comment: "")): \(xDimension)x\(yDimension) (\(resolutionString)MP)")
        }
        
        if let profile = imgProfile{
            fileElements.append("\(NSLocalizedString("image_profile", tableName: "AuxLocales", comment: "")): \(profile)")
        }
        
        fileSection.elements = fileElements
        imageData.append(fileSection)
    }
    
    func setImageData() {
        let tiff: JSON? = jsonMetadata?.TIFF
        let GPS: JSON? = jsonMetadata?.GPS
        let exifAux: JSON? = jsonMetadata?.ExifAux
        let exif: JSON? = jsonMetadata?.Exif
        
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonMetadata?.data, options: [.fragmentsAllowed]) {
            print(String(data: jsonData, encoding: .utf8)!) // JSON como texto
        }
        
        setFileProperties()
        
        if let tiffInfo = tiff{
            var cameraInfoSection = PhotoViewData(titleSection: "TIFF")
            cameraInfoSection.elements = getCameraInfo(tiffInfo)
            imageData.append(cameraInfoSection)
        }
        
        if let GPSData = GPS{
            var gpsInformation = PhotoViewData(titleSection: "GPS")
            gpsInformation.elements = getGPSData(GPSData)
            imageData.append(gpsInformation)
        }
        
        if let exifData = exif{
            var exifInfoTitle = LocalizedStringKey("EXIF")
            if let exifVersion: [Int] = exifData.ExifVersion{
                let version = exifVersion.map { String($0) }.joined(separator: ".")
                exifInfoTitle = LocalizedStringKey("EXIF (V. \(version))")
            }
            
            var exifInformation = PhotoViewData(titleSection: exifInfoTitle)
            exifInformation.elements = getEXIFData(exifData)
            imageData.append(exifInformation)
        }
        
        if let exifAuxData = exifAux{
            var exifAuxInformation = PhotoViewData(titleSection: "EXIF AUX")
            exifAuxInformation.elements = getExifAuxData(exifAuxData)
            imageData.append(exifAuxInformation)
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
