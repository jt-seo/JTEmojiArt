//
//  PaletteChooser.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/28.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State var showEmojiEditView: Bool = false

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
            Image(systemName: "keyboard").imageScale(.large)
                .popover(isPresented: $showEmojiEditView) {
                    PaletteEditor(chosenPalette: self.$chosenPalette, showPaletteEditor: self.$showEmojiEditView)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                }
                .onTapGesture {
                    self.showEmojiEditView = true
                }
        }
        .fixedSize()
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(chosenPalette: Binding.constant(""))
            .environmentObject(EmojiArtDocument())
    }
}
