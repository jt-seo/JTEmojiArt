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
    @Published private var emojiArt = EmojiArt()
    @Published private(set) var backgroundImage: UIImage?
    
    func setBackgroundImageURL(url: URL?) { // This function might be called from the background queue.
        DispatchQueue.main.async {
            self.emojiArt.backgroundImageURL = url?.imageURL
            print("ImageUrl: \(self.emojiArt.backgroundImageURL?.absoluteString ?? "empty")")
            self.fetchBackgroundImage(url: url)
        }
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
}
