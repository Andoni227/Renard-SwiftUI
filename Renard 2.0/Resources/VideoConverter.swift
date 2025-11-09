//
//  VideoConverter.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 04/11/25.
//

import AVFoundation
import Photos

class VideoConverter {
    static let shared = VideoConverter()
    var videoVersion: PHVideoRequestOptionsVersion = .current
    var preset: VideoExportPresets = .originalQualityH265
    var outputFileType: AVFileType = .mov
    var codec: VideoExportCodec = .H265
    
    func getPresetsFor(codec: VideoExportCodec) -> [VideoExportPresets] {
        switch codec {
        case .H264:
            return  [.originalQualityH264, .mediumQualityH264, .lowQualityH264]
        case .H265:
            return [.originalQualityH265, .H265_4k, .H265_1080p]
       // case .H265Alpha:
        //    return [.originalQualityH265Alpha, .H265_4KAlpha, .H265_1080pAlpha]
        }
    }
    
    func export(_ phAsset: PHAsset,
                completion: @escaping (URL?, Error?) -> Void,
                downloadProgressHandler: @MainActor @escaping (Double) -> Void, exportProgressHandler: @MainActor @escaping (Double) -> Void) {
        
        let options = PHVideoRequestOptions()
        options.version = videoVersion
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.progressHandler = { progress, error, pointer, anyHash in
            DispatchQueue.main.async{
                downloadProgressHandler(progress)
            }
        }
        
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { avAsset, audioMix, anyHash in
            guard let avAsset = avAsset else {
                completion(nil, VideoExportError.noVideoFile)
                return
            }
            
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(phAsset.getFileName() ?? UUID().uuidString + self.outputFileType.rawValue)
            guard let export = AVAssetExportSession(asset: avAsset, presetName: self.preset.rawValue) else {
                completion(nil, VideoExportError.unknown)
                return
            }
            
            print("Iniciando exportación: \(self.preset.rawValue)")
            
            export.outputURL = outputURL
            export.outputFileType = self.outputFileType

            
            
             _ = NotificationCenter.default.addObserver(
                        forName: .cancelExportNotification,
                        object: nil,
                        queue: .main
                    ) { [weak export] _ in
                        export?.cancelExport()
                        print("Exportación cancelada.")
                    }
            
            
            guard #available(iOS 18, *) else {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    let progress = Double(export.progress)
                    Task { @MainActor in
                        exportProgressHandler(progress)
                    }
                }
                
                export.exportAsynchronously {
                    timer.invalidate()
                    switch export.status {
                    case .completed:
                        completion(outputURL, nil)
                    default:
                        completion(nil, export.error)
                    }
                }
                return
            }
            
            Task {
                for await state in export.states(updateInterval: 0.1) {
                    switch state {
                    case .pending, .waiting:
                        break
                    case .exporting(progress: let progress):
                        await exportProgressHandler(progress.fractionCompleted)
                    @unknown default:
                        break
                    }
                }
            }
            
            export.exportAsynchronously {
                switch export.status {
                case .completed:
                    completion(outputURL, nil)
                default:
                    completion(nil, VideoExportError.unknown)
                }
            }
        }
    }
    
    private init() {
        
    }
}


enum VideoExportError: String, Error{
    case unknown = "Error desconocido"
    case noVideoFile = "El archivo no es un vídeo"
    case exportCanceled = "Exportación cancelada"
}

enum VideoExportPresets: String, CaseIterable {
    case originalQualityH264 = "AVAssetExportPresetHighestQuality"
    case mediumQualityH264 = "AVAssetExportPresetMediumQuality"
    case lowQualityH264 = "AVAssetExportPresetLowQuality"
    
    case originalQualityH265 = "AVAssetExportPresetHEVCHighestQuality"
    case originalQualityH265Alpha = "AVAssetExportPresetHEVCHighestQualityWithAlpha"
    case H265_4k = "AVAssetExportPresetHEVC3840x2160"
    case H265_4KAlpha = "AVAssetExportPresetHEVC3840x2160WithAlpha"
    case H265_1080p = "AVAssetExportPresetHEVC1920x1080"
    case H265_1080pAlpha = "AVAssetExportPresetHEVC1920x1080WithAlpha"
}

enum VideoExportCodec: String, CaseIterable{
    case H264 = "H.264"
    case H265 = "HEVC"
  //case H265Alpha = "HEVC_Alpha" TODO: Add transparency support
}

extension Notification.Name {
    static let cancelExportNotification = Notification.Name("CancelExportNotification")
}
