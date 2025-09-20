//
//  GlassEffectSupport.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 19/09/25.
//

import SwiftUI

struct AddGlassEffect: ViewModifier {
    var cornerRadius: CGFloat
    var legacyBackground: Color?
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: .rect(cornerRadius: cornerRadius))
        }else{
            content
                .background(legacyBackground)
        }
    }
}

extension View {
    func addGlassEffect(cornerRadius: CGFloat = 0, legacyBackground: Color? = nil) -> some View {
        modifier(AddGlassEffect(cornerRadius: cornerRadius))
    }
}
