//
//  EmojiArtDocumentView.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject private(set) var document: EmojiArtDocument
    
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    @State private var steadyPanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        (gesturePanOffset + steadyPanOffset) * zoomScale
    }
    
    private var zoomScale: CGFloat {
        return steadyZoomScale * gestureZoomScale
    }

    var body: some View {
        VStack {
            HStack {
                ForEach (EmojiArtDocument.palette.map { String($0) }, id: \.self) { text in
                    Text(text)
                        .font(Font.system(size: self.defaultEmojiFontSize))
                        .onDrag {
                            print("ondrag: \(text)")
                            return NSItemProvider(object: text as NSString)
                    }
                }
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(OptionalImage(image: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
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
                            .padding(5)
                            .emojiSelectEffect(selected: self.document.isSelected(emoji: emoji))
                            .position(emoji.position)
                            .animatableSystemFont(size: self.document.fontSize(for: emoji) * self.zoomScale)
                            .offset(self.document.isSelected(emoji: emoji) ? self.emojiMoveOffset : .zero)
                            .onTapGesture {
                                self.document.selectEmoji(emoji: emoji)
                            }
                        
                            
//                        ZStack {
//                            Text(emoji.text)
//                            .position(emoji.position)
//                            .animatableSystemFont(size: self.document.fontSize(for: emoji) * self.zoomScale)
//
//                            Circle().stroke(lineWidth: 5).foregroundColor(.red)
//                        }
                    }
                }
                .gesture(self.panToMoveDocument())
                .gesture(self.doubleTapToZoom(size: geometry.size))
                .onTapGesture {
                    self.document.deSelectAll()
                }
            }
            .clipped()
            .gesture(self.gestureZoom())

            Button("Reset") {
                self.reset()
            }
            .font(Font.system(size: self.defaultEmojiFontSize))
        }
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        // set background image url.
        var found = providers.loadProviderItem(ofType: URL.self) { url in
            self.document.setBackgroundImageURL(url: url)
            self.resetZoomScale()
        }
        if (!found) {
            found = providers.loadProviderItem(ofType: String.self) { text in
                self.document.addEmoji(text: text, location: location, size: self.defaultEmojiFontSize)
            }
        }
        return found
    }
    
    func doubleTapToZoom(size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear) {
                    self.zoomToFit(size: size)
                }
        }
    }
    
    @State private var toggleFitToWindow: Bool = false
    func zoomToFit(size: CGSize) {
        if let image = document.backgroundImage, image.size.width > 0 && image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyZoomScale = toggleFitToWindow ? max(hZoom, vZoom) : min(hZoom, vZoom)
            toggleFitToWindow.toggle()
            steadyPanOffset = .zero
        }
    }
    
    func gestureZoom() -> some Gesture {
        return MagnificationGesture()
            .updating($gestureZoomScale) { latestScale, gestureZoomScale, transaction in
                gestureZoomScale = latestScale
        }
            .onEnded { finalScale in
                print("MagnificationZoom ended. scale: \(self.steadyZoomScale), \(self.gestureZoomScale)")
                self.steadyZoomScale *= finalScale
        }
    }
    
    func resetZoomScale() {
        steadyZoomScale = 1.0
        toggleFitToWindow = false
    }
    
    func panToMoveDocument() -> some Gesture {
        emojiPanGesture().simultaneously(with: backgroundPanGesture())
    }
    
    @GestureState private var emojiMoveOffset: CGSize = .zero
    func emojiPanGesture() -> some Gesture {
        DragGesture()
            .updating($emojiMoveOffset) { dragInfo, emojiMoveOffset, transaction in
                if (self.document.selectedEmojiCount > 0) {
                    emojiMoveOffset = dragInfo.translation / self.zoomScale
                }
        }
            .onEnded { dragInfo in
                if (self.document.selectedEmojiCount > 0) {
                    self.document.moveSelectedEmojis(by: dragInfo.translation / self.zoomScale)
                    print("Move(Emoji) gesture ended. offset: \(dragInfo.translation / self.zoomScale)")
                }
        }
    }
    
    func backgroundPanGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { dragInfo, gesturePanOffset, transaction in
                if (self.document.selectedEmojiCount == 0) {
                    gesturePanOffset = dragInfo.translation / self.zoomScale
                }
        }
            .onEnded { dragInfo in
                if (self.document.selectedEmojiCount == 0) {
                    self.steadyPanOffset = self.steadyPanOffset + dragInfo.translation / self.zoomScale
                    print("Pan gesture ended. offset: \(self.steadyPanOffset), \(self.gesturePanOffset)")
                }
        }
    }
    
    func reset() {
        resetZoomScale()
        document.reset()
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
