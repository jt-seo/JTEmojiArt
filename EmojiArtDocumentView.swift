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
    
    @State var zoomScale: CGFloat = 1.0

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
                    Color.white
                        .overlay(OptionalImage(image: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
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
                .clipped()
                .gesture(self.fitToZoom(size: geometry.size))
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
    
    func fitToZoom(size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                print("fitToZoom")
                if let image = self.document.backgroundImage, image.size.width > 0 && image.size.height > 0 {
                    let hZoom = size.width / image.size.width
                    let vZoom = size.height / image.size.height
                    self.zoomScale = min(hZoom, vZoom)
                }
        }
    }
    
    struct OptionalImage: View {
        let image: UIImage?
        
        var body: some View {
            Group {
                if image != nil {
                    Image(uiImage: image!)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
