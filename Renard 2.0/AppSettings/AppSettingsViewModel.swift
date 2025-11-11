//
//  AppSettingsViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 09/06/25.
//

import Foundation
import SwiftUI

class AppSettingsViewModel: ObservableObject{
    @Published var showCompressionOptions = false
    @Published var showMapOptions = false
    
    func getCompression() -> LocalizedStringKey{
        let savedPreference = UserDefaults.standard.value(forKey: "compressionLevel") as? Double
        switch savedPreference{
        case 0.7:
            return "preferencesOption2_0"
        case 0.8:
            return "preferencesOption2_1"
        case 0.9:
            return "preferencesOption2_2"
        case 0.99, 1.0:
            return "preferencesOption2_3"
        default:
            return "preferencesOption2_0"
        }
    }
    
    func changeCompression(_ value: Double) {
        UserDefaults.standard.setValue(Double(String(format: "%.1f", value)), forKey: "compressionLevel")
    }
    
    func getPreferedMaps() -> String{
        return UserDefaults.standard.value(forKey: "preferedMaps") as? String ?? "Apple Maps"
    }
    
    func changePreferedMaps(_ value: String) {
        UserDefaults.standard.setValue(value, forKey: "preferedMaps")
    }
    
    func cleanCache() {
        AppCleaner().clearTemporalDirectory()
    }
}
