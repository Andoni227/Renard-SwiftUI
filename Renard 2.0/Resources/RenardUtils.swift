//
//  RenardUtils.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 22/05/25.
//
import Photos


enum Router: Hashable{
    case preferences
    case statistics
}

struct AssetObject{
    var asset: PHAsset
    var format: ImageType
    var resolution: Int
    var isSelected: Bool?
}

struct FormatObject: Comparable, Hashable, Identifiable{
    var id: UUID
    var imageType: ImageType
    var count: Int
    
    static func < (lhs: FormatObject, rhs: FormatObject) -> Bool {
        return lhs.count < rhs.count
    }
}

enum ImageType: String{
    
    case RAW = "com.adobe.raw-image"
    case RAF = "com.fuji.raw-image"
    case ARW = "com.sony.arw-raw-image"
    case NEF = "com.nikon.raw-image"
    case CR3 = "com.canon.cr3-raw-image"
    case GIF = "com.compuserve.gif"
    case JPG = "public.jpeg"
    case HEIC = "public.heic"
    case PNG = "public.png"
    case TIFF = "public.tiff"
    case WEBP = "org.webmproject.webp"
    case UNOWNED = ""
    case NOTIMAGE = "video"
    case AVIF = "public.avif"
    
    var name: String {
            switch self {
            case .RAW:
                return "RAW"
            case .RAF:
                return "RAF"
            case .ARW:
                return "ARW"
            case .NEF:
                 return "NEF"
            case .CR3:
                return "CR3"
            case .GIF:
                return "GIF"
            case .JPG:
                return "JPG"
            case .HEIC:
                return "HEIC"
            case .PNG:
                return "PNG"
            case .TIFF:
                return "TIFF"
            case .WEBP:
                return "WEBP"
            case .AVIF:
                return "AVIF"
            case .UNOWNED:
                return "RAW"
            case .NOTIMAGE:
                return "Desconocido"
            }
        }
}

