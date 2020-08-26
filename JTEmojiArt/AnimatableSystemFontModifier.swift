//
//  AnimatableSystemFontModifier.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/26.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct AnimatableSystemFontModifier: AnimatableModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content.font(Font.system(size: CGFloat(size) ))
    }
    
    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
}

extension View {
    func animatableSystemFont(size: CGFloat) -> some View {
        return modifier(AnimatableSystemFontModifier(size: size))
    }
}
