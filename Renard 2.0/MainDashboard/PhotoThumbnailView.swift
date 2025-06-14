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
    let isSelected: Bool
    let action: () -> Void
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            Button(action: action, label: {
                ZStack{
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .opacity(isSelected ? 0.4 : 1)
                    } else {
                        Color.gray.opacity(0.3)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(4)
                    }
                }
            })
        }
        .frame(width: size, height: size)
        .clipped()
        .cornerRadius(10)
        .onAppear {
            loadThumbnail()
        }
        .onDisappear {
            self.image = nil
        }
    }
    
    private func loadThumbnail() {
        let identifier = asset.localIdentifier
        
        if let cachedImage = ImageCache.shared.image(for: identifier) {
            self.image = cachedImage
            return
        }
        
        let manager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        
        let size = CGSize(width: self.size, height: self.size)
        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            if let result = result {
                ImageCache.shared.set(result, for: identifier)
                self.image = result
            }
        }
    }
}
