//
//  EmojiArtDocumentView.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        VStack {
            HStack {
                ForEach (EmojiArtDocument.palette.map { String($0) }, id: \.self) { text in
                    Text(text)
                        .font(Font.system(size: self.defaultEmojiFontSize))
                        .onDrag {
                            NSItemProvider(object: text as NSString)
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.green
                    .overlay(
                        Group {
                            if self.document.backgroundImage != nil {
                                Image(uiImage: self.document.backgroundImage!)
                                    .resizable()
                            }
                        }
                    )
                    .edgesIgnoringSafeArea([.bottom, .horizontal])
                    .onDrop(of: ["public.image", "public.plain-text"], isTargeted: nil) { providers, location in
                        // convert from the global coordinate to view coordinate.
                        let origin = geometry.frame(in: .global).origin // the origin of this geometry in the global coordinate system.
                        let location = location - origin
                        return self.drop(providers: providers, location: location)
                    }
                    
                    ForEach(self.document.emojis) {emoji in
                        Text(emoji.text)
                            .position(emoji.position)
                            .font(self.document.fontSize(for: emoji))
                    }
                }
            }
        }
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        // set background image url.
        var found = providers.loadProviderItem(ofType: URL.self) { url in
            self.document.setBackgroundImageURL(url: url)
        }
        if (!found) {
            found = providers.loadProviderItem(ofType: String.self) { text in
                self.document.addEmoji(text: text, location: location, size: self.defaultEmojiFontSize)
            }
        }
        return found
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
