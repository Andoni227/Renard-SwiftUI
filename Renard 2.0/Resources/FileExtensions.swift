//
//  FileExtensions.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 15/11/25.
//

import Foundation

class FileProvider {
    
    private func getFileName(urlPath: String) -> String {
        let fileNameWithoutExtension = urlPath.split(separator: ".").dropLast().joined(separator: ".")
        return fileNameWithoutExtension
    }
    
    func accessSecurityScopedResource(from url: URL, handler: (URL, String, String) -> Void) {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer {
            if needsAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let coordinator = NSFileCoordinator()
        var error: NSError?

        coordinator.coordinate(readingItemAt: url, options: [], error: &error) { newURL in
            handler(newURL, newURL.lastPathComponent, getFileName(urlPath: newURL.lastPathComponent))
        }

        if let error {
            print("Error al coordinar acceso:", error)
        }
    }

    
}
