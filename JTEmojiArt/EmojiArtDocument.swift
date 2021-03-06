//
//  EmojiArtDocument.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable {
    @Published private var emojiArt: EmojiArt
    @Published private(set) var backgroundImage: UIImage?
    
    @Published var steadyZoomScale: CGFloat = 1.0
    @Published var steadyPanOffset: CGSize = .zero
    
    var autoCancellable: AnyCancellable?
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    
    init (id: UUID? = nil) {
        if let id = id {
            self.id = id
        }
        else {
            self.id = UUID()
        }
        
        let jsonKeyName = "EmojiArtDocument.\(self.id.uuidString)"

        if let data = UserDefaults.standard.data(forKey: jsonKeyName), let newEmojiArt = EmojiArt(json: data) {
            emojiArt = newEmojiArt
            print("imageUrl: \(emojiArt.backgroundImageURL?.absoluteString ?? "nil")")
            fetchBackgroundImage()
        }
        else {
            emojiArt = EmojiArt()
        }
        
        autoCancellable = $emojiArt.sink { emojiArt in
            if let json = emojiArt.json {
                UserDefaults.standard.set(json, forKey: jsonKeyName)
            }
        }
    }
    
    var url: URL? {
        didSet { self.save(self.emojiArt) }
    }
    init (url: URL) {
        self.id = UUID()
        self.url = url
        emojiArt = EmojiArt(json: try? Data(contentsOf: url)) ?? EmojiArt()
        fetchBackgroundImage()
        autoCancellable = $emojiArt.sink { emojiArt in
            self.save(emojiArt)
        }
    }
    
    private func save(_ emojiArt: EmojiArt) {
        if let url = url {
            try? emojiArt.json?.write(to: url)
        }
    }
    
    var backgroundImageURL: URL? {
        get { self.emojiArt.backgroundImageURL }
        set {
            self.emojiArt.backgroundImageURL = newValue
            print("ImageUrl: \(self.emojiArt.backgroundImageURL?.absoluteString ?? "empty")")
            self.fetchBackgroundImage()
        }
    }
    private var dataTask: URLSessionDataTask?
    private func fetchBackgroundImage() {
        if let url = self.backgroundImageURL {
            print("Fetch image: \(url)")
//            backgroundImageCancellable = URLSession.shared
//                .dataTaskPublisher(for: url)
//                .map { data, urlResponse in
//                    print("data map")
//                    return UIImage(data: data)
//                }
//                .receive(on: DispatchQueue.main)
//                .replaceError(with: nil)    // return publisher
//                .assign(to: \.backgroundImage, on: self) // publisher.assign returns the cancellable for this subscribing.
            
            dataTask?.cancel()
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { (data, urlResponse, error) in
                if let data = data {
                    print("data received")
                    print(data)
                    DispatchQueue.main.async {
                        self.backgroundImage = UIImage(data: data)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func addEmoji(text: String, location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(text: text, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(for emoji: EmojiArt.Emoji, by offset: CGSize) {
        emojiArt.moveEmoji(for: emoji, byX: Int(offset.width), byY: Int(offset.height))
    }
    func moveSelectedEmojis(by offset: CGSize) {
        for emoji in selectedEmojis {
            moveEmoji(for: emoji, by: offset)
        }
        print("moveSelectedEmojis: \(offset), count: \(selectedEmojiCount)")
    }
    
    var emojis: [EmojiArt.Emoji] {
        emojiArt.emojis
    }
    
    func fontSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    func changeSelectedEmojiSize(scale: CGFloat) {
        let scale = Double(scale)
        for emoji in selectedEmojis {
            if isSelected(emoji: emoji) {
                emojiArt.changeSize(for: emoji, by: Double(scale))
            }
        }
    }
    
    func reset() {
        print("reset called")
        backgroundImage = nil
        emojiArt = EmojiArt()
    }
    
    @Published private(set) var selectedEmojis: Set<EmojiArt.Emoji> = []
    func selectEmoji(emoji: EmojiArt.Emoji) {
        if selectedEmojis.firstIndex(matching: emoji) == nil {
            selectedEmojis.insert(emoji)
        }
        else {
            selectedEmojis.remove(matching: emoji)
        }
        print("selectEmoji. count: \(selectedEmojiCount)")
    }
    
    func isSelected(emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.firstIndex(matching: emoji) != nil
    }
    
    func deSelect(emoji: EmojiArt.Emoji) {
        selectedEmojis.remove(matching: emoji)
        print("deSelect: \(emoji.text), count: \(selectedEmojiCount)")
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
