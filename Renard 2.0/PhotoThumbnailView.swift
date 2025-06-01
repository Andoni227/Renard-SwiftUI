//
//  PhotoThumbnailView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 24/05/25.
//
import SwiftUI
import Photos

struct PhotoThumbnailView: View {
    let asset: PHAsset
    let size: CGFloat
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(10)
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        let size = CGSize(width: 200, height: 230)
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            if let result = result {
                self.image = result
            }
        }
    }
}
