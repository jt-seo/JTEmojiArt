//
//  EmojiArt.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import Foundation

struct EmojiArt: Codable {
    var emojis = [Emoji]()
    var emojiUniqueId = 0
    var backgroundImageURL: URL?

    mutating func addEmoji(text: String, x: Int, y: Int, size: Int) {
        let emoji = Emoji(id: emojiUniqueId, text: text, x: x, y: y, size: size)
        emojis.append(emoji)
        emojiUniqueId += 1
    }
    
    mutating func moveEmoji(for emoji: Emoji, byX offsetX: Int, byY offsetY: Int) {
        if let idx = emojis.firstIndex(matching: emoji) {
            emojis[idx].x += offsetX
            emojis[idx].y += offsetY
        }
    }
    
    mutating func changeSize(for emoji: Emoji, by scale: Double) {
        if let idx = emojis.firstIndex(matching: emoji) {
            let newSize = Int(Double(emojis[idx].size) * scale)
            print("changeSize[\(emoji.text)] from \(emoji.size) to \(newSize), scale: \(scale)")
            emojis[idx].size = newSize
        }
    }
    
    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    init? (json: Data?) {
        if let json = json, let decoded = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = decoded
        }
    }
    
    init() { }
    
    struct Emoji: Identifiable, Codable, Hashable {
        let id: Int

        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
}
