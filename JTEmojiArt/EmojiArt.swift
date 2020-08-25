//
//  EmojiArt.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import Foundation

struct EmojiArt {
    var emojis = [Emoji]()
    var emojiUniqueId = 0
    var backgroundImageURL: URL?

    mutating func addEmoji(text: String, x: Int, y: Int, size: Int) {
        let emoji = Emoji(id: emojiUniqueId, text: text, x: x, y: y, size: size)
        emojis.append(emoji)
        emojiUniqueId += 1
    }
    
    struct Emoji: Identifiable {
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
