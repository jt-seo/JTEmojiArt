//
//  PaletteEditor.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/09/03.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var paletteName: String = ""
    @State private var emojiToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Palette Editor").font(.headline).padding()
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojiToAdd, onEditingChanged: { began in
                        if !began {
                            self.document.addEmoji(self.emojiToAdd, toPalette: self.chosenPalette)
                        }
                    })
                    ForEach (chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.defaultEmojiFontSize))
                    }
                }
            }
            .onAppear {
                self.paletteName = self.document.paletteNames[self.chosenPalette] ?? ""
            }
        }
        
    }
    
    private let defaultEmojiFontSize: CGFloat = 40
}
