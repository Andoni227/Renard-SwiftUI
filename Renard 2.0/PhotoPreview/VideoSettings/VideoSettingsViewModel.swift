//
//  VideoSettingsViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 07/11/25.
//

import SwiftUI

class VideoSettingsViewModel: ObservableObject{
    
    @Published var showCodecs = false
    @Published var showPresets = false
    @Published var showFormats = false
    
    var videoConverter = VideoConverter.shared
    
    func getVideoCodecName() -> String{
        return videoConverter.codec.rawValue
    }
    
    func getVideoFormatName() -> String{
        return videoConverter.outputFileType.rawValue
    }
    
    func getVideoPresetName(_ preset: VideoExportPresets? = nil) -> String{
        switch preset ?? videoConverter.preset{
        case .originalQualityH264, .originalQualityH265, .originalQualityH265Alpha:
            return NSLocalizedString("highest_quality", tableName: "AuxLocales", comment: "")
        case .mediumQualityH264:
            return NSLocalizedString("medium_quality", tableName: "AuxLocales", comment: "")
        case .lowQualityH264:
            return NSLocalizedString("low_quality", tableName: "AuxLocales", comment: "")
        case .H265_4k, .H265_4KAlpha:
            return NSLocalizedString("ultraHD", tableName: "AuxLocales", comment: "")
        case .H265_1080p, .H265_1080pAlpha:
            return NSLocalizedString("fullHD", tableName: "AuxLocales", comment: "")
        }
    }
    
    func setDefaultPreset(for codec: VideoExportCodec){
        switch codec{
        case .H264:
            videoConverter.preset = .originalQualityH264
        case .H265:
            videoConverter.preset = .originalQualityH265
       // case .H265Alpha:
       //     videoConverter.preset = .originalQualityH265Alpha
        }
    }
    
    @ViewBuilder
    func getFormatOptions() -> some View {
        ForEach(VideoExportFormat.allCases, id: \.self) { format in
            Button(format.rawValue) {
                self.videoConverter.outputFileType = format
            }
        }
    }
    
    @ViewBuilder
    func getPresetOptions() -> some View {
        ForEach(videoConverter.getPresetsFor(codec: videoConverter.codec), id: \.self) { preset in
            Button( NSLocalizedString(self.getVideoPresetName(preset), tableName: "AuxLocales", comment: "")) {
                self.videoConverter.preset = preset
            }
        }
    }
    
    @ViewBuilder
    func getCodecOptions() -> some View {
        ForEach(VideoExportCodec.allCases, id: \.self) { codec in
            Button( NSLocalizedString(codec.rawValue, tableName: "AuxLocales", comment: "")) {
                self.videoConverter.codec = codec
                self.setDefaultPreset(for: codec)
            }
        }
    }
    
}
