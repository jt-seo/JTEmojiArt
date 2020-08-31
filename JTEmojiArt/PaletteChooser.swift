//
//  PaletteChooser.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/28.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    private(set) var document: EmojiArtDocument
    @Binding var chosenPalette: String

    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: {
                EmptyView()
            })
            Text(document.paletteNames[chosenPalette] ?? "nil")
        }
        .fixedSize()
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: Binding.constant(""))
    }
}
