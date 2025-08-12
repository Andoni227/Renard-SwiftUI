//
//  RenardUtils.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 22/05/25.
//
import Photos
import SwiftUI

enum Router: Hashable, Equatable{
    case preferences
    case statistics
    case photoInfo(asset: AssetObject)
    
    @ViewBuilder
    var view: some View {
        switch self{
        case .preferences: AppSettings()
        case .statistics: GalleryStatistics()
        case .photoInfo(let asset): PhotoInfoView(asset: asset)
        }
    }
}

struct AssetObject: Identifiable, Hashable{
    var id: String { asset.localIdentifier }
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

extension PHAsset{
    func getSize(format: SizeFormat? = .normal) -> String{
        let resources = PHAssetResource.assetResources(for: self)
        var sizeOnDisk: Int64? = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
        }
        
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        if let estimatedSize = sizeOnDisk{
            switch format{
            case .normal:
                return estimatedSize.bytesToReadableSize()
            case .kb:
                return String(Double(estimatedSize)/1000.0)
            case .mb:
                return String(Double(estimatedSize)/1000000.0)
            case .raw:
                return String(estimatedSize)
            case .none:
                return NSLocalizedString("unknown", comment: "")
            }
        }else{
            return NSLocalizedString("unknown", comment: "")
        }
    }
}

extension Int64{
    func bytesToReadableSize() -> String{
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: self)
    }
}

enum SizeFormat{
    case normal
    case mb
    case kb
    case raw
}
