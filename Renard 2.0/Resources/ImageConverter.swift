//
//  ImageConverter.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 02/06/25.
//

import Photos

class ImageConverter{
    func convertAndSaveAssetAsHEIF(from asset: PHAsset, completion: @escaping (Bool, Error?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, uti, _, _ in
            guard
                let data = data,
                let source = CGImageSourceCreateWithData(data as CFData, nil)
            else {
                completion(false, NSError(domain: "HEIFConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener imagen del asset"]))
                return
            }
            
            var originalFilename = "converted.heic"
            if let assetResource = PHAssetResource.assetResources(for: asset).first {
                let baseName = (assetResource.originalFilename as NSString).deletingPathExtension
                originalFilename = "\(baseName).heic"
            }
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("heic")
            
            guard let destination = CGImageDestinationCreateWithURL(tempURL as CFURL, AVFileType.heic as CFString, 1, nil) else {
                completion(false, NSError(domain: "HEIFConversion", code: -2, userInfo: [NSLocalizedDescriptionKey: "No se pudo crear el destino HEIC"]))
                return
            }
            
            let compressionLevel = UserDefaults.standard.value(forKey: "compressionLevel")
            
            let compressionOptions: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: compressionLevel ?? 0.7
            ]
            
            CGImageDestinationAddImageFromSource(destination, source, 0, compressionOptions as CFDictionary)
            
            guard CGImageDestinationFinalize(destination) else {
                completion(false, NSError(domain: "HEIFConversion", code: -3, userInfo: [NSLocalizedDescriptionKey: "No se pudo finalizar la exportación HEIC"]))
                return
            }
            
            guard let heifData = try? Data(contentsOf: tempURL) else {
                completion(false, NSError(domain: "HEIFConversion", code: -4, userInfo: [NSLocalizedDescriptionKey: "No se pudo leer el archivo HEIC"]))
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                
                let fileOptions = PHAssetResourceCreationOptions()
                fileOptions.originalFilename = originalFilename
                
                creationRequest.addResource(with: .photo, data: heifData, options: fileOptions)
                creationRequest.creationDate = asset.creationDate
                
                if let location = asset.location {
                    creationRequest.location = location
                }
                
            } completionHandler: { success, error in
                completion(success, error)
            }
        }
    }
    
    private func convertAndSaveAssetAsHEIF(from asset: PHAsset) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.convertAndSaveAssetAsHEIF(from: asset) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? NSError(domain: "HEIFConversion", code: -999, userInfo: nil))
                }
            }
        }
    }
    
    func convertAndSaveAssetsAsHEIF(
        from assets: [PHAsset],
        progressHandler: @MainActor @escaping (Double) -> Void
    ) async throws -> [(Bool, Error?)] {
        let total = assets.count
        var completed = 0
        var results = Array<(Bool, Error?)>(repeating: (false, nil), count: total)
        try Task.checkCancellation()
        try await withThrowingTaskGroup(of: (Int, Bool, Error?).self) { group in
            for (index, asset) in assets.enumerated() {
                group.addTask {
                    try Task.checkCancellation()
                    do {
                        try await self.convertAndSaveAssetAsHEIF(from: asset)
                        return (index, true, nil)
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        return (index, false, error)
                    }
                }
            }
            
            for try await (index, success, error) in group {
                results[index] = (success, error)
                completed += 1
                try Task.checkCancellation()
                let progress = Double(completed) / Double(total)
                await progressHandler(progress)
            }
        }

        return results
    }
}

extension ObservableObject{
    func deleteAsset(identifiers: [String], completion: @escaping (Bool, Error?) -> Void){
        PHPhotoLibrary.shared().performChanges({
            let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            var itemsToDelete: [PHAsset] = []
            
            assetToDelete.enumerateObjects({ photo ,_,_ in
                itemsToDelete.append(photo)
            })
            PHAssetChangeRequest.deleteAssets(itemsToDelete as NSArray)
        }, completionHandler: completion)
    }
}
