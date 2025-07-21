//
//  AppCleaner.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 02/06/25.
//

import Foundation
import UIKit

class AppCleaner{
    func clearTemporalDirectory() {
        let fileManager = FileManager.default
        let temporaryDirectoryURL = fileManager.temporaryDirectory

        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: temporaryDirectoryURL, includingPropertiesForKeys: nil, options: [])
            for fileURL in directoryContents {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing temporary directory: \(error.localizedDescription)")
        }
    }
}

class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]

    func image(for key: String) -> UIImage? {
        return cache[key]
    }

    func set(_ image: UIImage, for key: String) {
        cache[key] = image
    }
}
