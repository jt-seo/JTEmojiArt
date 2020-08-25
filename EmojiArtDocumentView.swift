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
                }
            }
            Color.green
                .overlay(
                    Group {
                        if self.document.backgroundImage != nil {
                            Image(uiImage: self.document.backgroundImage!)
                                //.resizable()
                        }
                    }
                )
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .onDrop(of: ["public.image"], isTargeted: nil) { providers, location in
                    return self.drop(providers: providers, location: location)
                }
        }
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        // set background image url.
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self, completionHandler: {url, _  in
                self.document.setBackgroundImageURL(url: url)
            })
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
