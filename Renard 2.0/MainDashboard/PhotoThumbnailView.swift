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
    let imageManager: PHImageManager
    let managerOptions: PHImageRequestOptions
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
    }
    
    private func loadThumbnail() {
        Task { @MainActor in
            let size = CGSize(width: self.size, height: self.size)
            managerOptions.isSynchronous = false
            managerOptions.deliveryMode = .opportunistic
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: managerOptions) { (image, _) in
                
                if let result = image {
                    self.image = result
                }
                
            }
        }
    }
}
