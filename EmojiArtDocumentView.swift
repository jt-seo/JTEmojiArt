//
//  EmojiArtDocumentView.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    var emojiArt: EmojiArtDocument
    var body: some View {
        VStack {
            HStack {
                ForEach (EmojiArtDocument.palette.map { String($0) }, id: \.self) { text in
                    Text(text)
                        .font(Font.system(size: self.defaultEmojiFontSize))
                }
            }
            Color.green
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .onDrop(of: ["public.image"], isTargeted: nil) { providers, location in
                    return true
                }
        }
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        // set background image url.
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(emojiArt: EmojiArtDocument())
    }
}
