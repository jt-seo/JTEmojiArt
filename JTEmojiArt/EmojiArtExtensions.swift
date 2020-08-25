//
//  EmojiArtExtensions.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import Foundation

extension URL {
    var imageURL: URL? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        
        if let queryItems = components.percentEncodedQueryItems {
            for query in queryItems {
                if query.name == "imgurl", let url = query.value {
                    return URL(string: url)
                }
            }
        }
        return self
    }
}

extension Array where Element: NSItemProvider {
    func loadProviderItem<T> (ofType: T.Type, completeHandler: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        var found = false
        if let provider = first(where: {$0.canLoadObject(ofClass: ofType)}) {
            found = true
            _ = provider.loadObject(ofClass: ofType) { item, error in
                if let item = item {
                    DispatchQueue.main.async {
                        completeHandler(item)
                    }
                }
            }
        }
        return found
    }
    
}


import SwiftUI

extension CGPoint {
    static func - (_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x - b.x, y: a.y - b.y)
    }
    
    static func + (_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x + b.x, y: a.y + b.y)
    }
}

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
