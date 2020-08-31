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

extension CGSize {
    static func - (_ a: CGSize, _ b: CGSize) -> CGSize {
        return CGSize(width: a.width - b.width, height: a.height - b.height)
    }
    
    static func + (_ a: CGSize, _ b: CGSize) -> CGSize {
        return CGSize(width: a.width + b.width, height: a.height + b.height)
    }
    
    static func * (_ a: CGSize, _ number: CGFloat) -> CGSize {
        return CGSize(width: a.width * number, height: a.height * number)
    }
    
    static func / (_ a: CGSize, _ number: CGFloat) -> CGSize {
        return CGSize(width: a.width / number, height: a.height / number)
    }
}

struct EmojiSelectEffect: ViewModifier {
    let selected: Bool
    func body(content: Content) -> some View {
        Group {
            if (selected) {
                content
                    .padding(5)
                    .overlay(Circle().stroke(lineWidth: 4).foregroundColor(.red))
            }
            else {
                content
            }
        }
    }
}

extension View {
    func emojiSelectEffect(selected: Bool) -> some View {
        modifier(EmojiSelectEffect(selected: selected))
    }
}

struct Spinning: ViewModifier {
    @State private var isVisible: Bool = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear {
                self.isVisible = true
        }
    }
}

extension View {
    func spinning() -> some View {
        //modifier(Spinning(isVisible: isVisible))
        modifier(Spinning())
    }
}
