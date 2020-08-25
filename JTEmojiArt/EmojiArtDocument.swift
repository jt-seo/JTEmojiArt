//
//  EmojiArtDocument.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static var palette = "🇰🇷😓🖐👀☘️🍎🍌🏓"
    @Published private var emojiArt: EmojiArt {
        didSet {
            print("didSet")
            if let json = emojiArt.json {
                print(json)
                UserDefaults.standard.set(json, forKey: jsonKeyName)
            }
        }
    }
    @Published private(set) var backgroundImage: UIImage?
    
    init () {
        if let data = UserDefaults.standard.data(forKey: jsonKeyName), let newEmojiArt = EmojiArt(json: data) {
            emojiArt = newEmojiArt
            print("imageUrl: \(emojiArt.backgroundImageURL?.absoluteString ?? "nil")")
            fetchBackgroundImage(url: emojiArt.backgroundImageURL)
        }
        else {
            emojiArt = EmojiArt()
        }
    }
    
    private let jsonKeyName = "EmojiArtDocument.Untitled"
    
    func setBackgroundImageURL(url: URL?) { // This function might be called from the background queue.
        self.emojiArt.backgroundImageURL = url?.imageURL
        print("ImageUrl: \(self.emojiArt.backgroundImageURL?.absoluteString ?? "empty")")
        self.fetchBackgroundImage(url: url)
    }
    
    private func fetchBackgroundImage(url: URL?) {
        if let url = url {
            print("Download image: \(url)")
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: url) {
                    print("Image downloaded.")
                    DispatchQueue.main.async {
                        self.backgroundImage = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func addEmoji(text: String, location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(text: text, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    var emojis: [EmojiArt.Emoji] {
        emojiArt.emojis
    }
    
    func fontSize(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: CGFloat(emoji.size))
    }
}

extension EmojiArt.Emoji {
    var position: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
