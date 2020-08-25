//
//  EmojiArtDocumentView.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    private var emojiArt: EmojiArtDocument
    var body: some View {
        Text("Hello, World!!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(emojiArt: EmojiArtDocument())
    }
}
