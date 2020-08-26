//
//  EmojiArtDocument.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static var palette = "🇰🇷😓🖐👀☘️🍎🍌🏓🌈🌕🌙"
    @Published private var emojiArt: EmojiArt {
        didSet {
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
    
    func moveEmoji(for emoji: EmojiArt.Emoji, by offset: CGSize) {
//        print("moveEmoji: \(offset)")
        emojiArt.moveEmoji(for: emoji, byX: Int(offset.width), byY: Int(offset.height))
    }
    func moveSelectedEmojis(by offset: CGSize) {
        print("moveSelectedEmojis: \(offset), before count: \(selectedEmojiCount)")
        for emoji in selectedEmojis {
            moveEmoji(for: emoji, by: offset)
        }
        print("moveSelectedEmojis: \(offset), after count: \(selectedEmojiCount)")
    }
    
    var emojis: [EmojiArt.Emoji] {
        emojiArt.emojis
    }
    
    func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    func reset() {
        backgroundImage = nil
        emojiArt = EmojiArt()
    }
    
    @Published private(set) var selectedEmojis: Set<EmojiArt.Emoji> = []
    func selectEmoji(emoji: EmojiArt.Emoji) {
        print("selectEmoji")
        if selectedEmojis.firstIndex(of: emoji) != nil {
            selectedEmojis.remove(emoji)
        }
        else {
            selectedEmojis.insert(emoji)
        }
    }
    
    func isSelected(emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.firstIndex(of: emoji) != nil ? true : false
    }
    
    func deSelect(emoji: EmojiArt.Emoji) {
        selectedEmojis.remove(emoji)
        print("deSelect: \(emoji.text)")
    }
    
    func deSelectAll() {
        selectedEmojis = []
        print("deSelectAll")
    }
    
    var selectedEmojiCount: Int {
        selectedEmojis.count
    }
}

extension EmojiArt.Emoji {
    var position: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
