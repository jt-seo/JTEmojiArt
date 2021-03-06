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
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    @State private var chosenPalette: String = ""

    private var panOffset: CGSize {
        (gesturePanOffset + document.steadyPanOffset) * zoomScale
    }
    
    private var zoomScale: CGFloat {
        return document.steadyZoomScale * gestureZoomScale
    }
    
    private var isLoading: Bool {
        document.backgroundImageURL != nil && document.backgroundImage == nil
    }
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }

    var body: some View {
        VStack {
            HStack {
                PaletteChooser(chosenPalette: $chosenPalette)
                    .environmentObject(self.document)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach (chosenPalette.map { String($0) }, id: \.self) { text in
                            Text(text)
                                .font(Font.system(size: self.defaultEmojiFontSize))
                                .onDrag {
                                    print("ondrag: \(text)")
                                    return NSItemProvider(object: text as NSString)
                            }
                        }
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
                    
                    if self.isLoading {
                        Image(systemName: "hourglass")
                            .imageScale(.large)
                            .spinning()
                    }
                    else {
                        ForEach(self.document.emojis) {emoji in
                            Text(emoji.text)
                                .padding(5)
                                .emojiSelectEffect(selected: self.document.isSelected(emoji: emoji))
                                .position(emoji.position)
                                .animatableSystemFont(size: self.emojiSize(for: emoji))
                                .offset(self.document.isSelected(emoji: emoji) ? self.emojiMoveOffset : .zero)
                                .onTapGesture {
                                    self.document.selectEmoji(emoji: emoji)
                                }
                        }
                    }
                }
                    .clipped()
                    .simultaneousGesture(self.gestureZoom())
                    .simultaneousGesture(self.emojiGestureZoom())
                    .simultaneousGesture(self.emojiPanGesture())
                    .simultaneousGesture(self.backgroundPanGesture())
                    .gesture(self.doubleTapToZoom(size: geometry.size))
                    .onTapGesture {
                        self.document.deSelectAll()
                    }
                    .onReceive(self.document.$backgroundImage) { image in
                        if let image = image {
                            print("onReceive: image size: \(image.size.width) * \(image.size.height)")
                            self.zoomToFit(image, size: geometry.size)
                        }
                        else {
                            print("onReceive: image is null")
                        }
                    }
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                        // convert from the global coordinate to view coordinate.
                        let origin = geometry.frame(in: .global).origin // the origin of this geometry in the global coordinate system.
                        let location = location - origin
                        
                        print("onDrop: \(location), origin: \(origin)")
                        return self.drop(providers: providers, location: location)
                    }
                .alert(isPresented: self.$confirmBackgroundPaste) { Alert(
                    title: Text("Confirm Background Paste"),
                    message: Text("Do you really want to replace to background image to \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                    primaryButton: .default(Text("OK")) {
                        self.document.backgroundImageURL = UIPasteboard.general.url
                    },
                    secondaryButton: .cancel())
                }
            }
            
            
            
//            Button("Reset") {
//                self.reset()
//            }
//            .font(Font.system(size: self.defaultEmojiFontSize))
        }
        .navigationBarItems(leading: pickImage, trailing: Button(action: {
            if let url = UIPasteboard.general.url, url != self.document.backgroundImageURL {
                self.confirmBackgroundPaste = true
            } else {
                self.explainBackgroundPaste = true
            }
        }, label: {
            Image(systemName: "doc.on.clipboard").imageScale(.large)
                .alert(isPresented: self.$explainBackgroundPaste) {
                    Alert(title: Text("Background Image"),
                          message: Text("Copy background image first and then click the button to set the background image"),
                          dismissButton: .default(Text("OK")))
                }
        }))
    }
    
    @State private var showImagePicker = false
    
    var pickImage: some View {
        Image(systemName: "photo").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
            showImagePicker = true
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker()
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    func emojiSize(for emoji: EmojiArt.Emoji) -> CGFloat {
        self.document.fontSize(for: emoji) * self.zoomScale * (document.isSelected(emoji: emoji) ? self.emojiZoomScale : 1)
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
    
    func drop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        // set background image url.
        var found = providers.loadProviderItem(ofType: URL.self) { url in
            self.document.backgroundImageURL = url
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
                    self.zoomToFit(self.document.backgroundImage, size: size)
                }
        }
    }
    
    func zoomToFit(_ image: UIImage?, size: CGSize) {
        if let image = image, image.size.width > 0 && image.size.height > 0 && size.width > 0 && size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyZoomScale = min(hZoom, vZoom)
            document.steadyPanOffset = .zero
            print("zoomToFit. scale: \(document.steadyZoomScale)")
        }
    }
    
    func gestureZoom() -> some Gesture {
        return MagnificationGesture()
            .updating($gestureZoomScale) { latestScale, gestureZoomScale, transaction in
                if (self.document.selectedEmojiCount == 0) {
                    gestureZoomScale = latestScale
                }
        }
            .onEnded { finalScale in
                if (self.document.selectedEmojiCount == 0) {
                    print("MagnificationZoom ended. scale: \(self.document.steadyZoomScale), \(self.gestureZoomScale)")
                    self.document.steadyZoomScale *= finalScale
                }
        }
    }
    
    @GestureState private var emojiZoomScale: CGFloat = 1.0
    private func emojiGestureZoom() -> some Gesture {
        return MagnificationGesture()
            .updating($emojiZoomScale) { latestScale, emojiZoomScale, transaction in
                if (self.document.selectedEmojiCount > 0) {
                    emojiZoomScale = latestScale
                }
            }
            .onEnded { finalScale in
                if (self.document.selectedEmojiCount > 0) {
                    self.document.changeSelectedEmojiSize(scale: finalScale)
                    print("emojiGestureZoom ended. scale: \(finalScale)")
                }
            }
    }
    
    func resetZoomScale() {
        document.steadyZoomScale = 1.0
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
                    self.document.steadyPanOffset = self.document.steadyPanOffset + dragInfo.translation / self.zoomScale
                    print("Pan gesture ended. offset: \(self.document.steadyPanOffset), \(self.gesturePanOffset)")
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
