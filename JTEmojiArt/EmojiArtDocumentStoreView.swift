//
//  EmojiArtDocumentStoreView.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/09/04.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentStoreView: View {
    @ObservedObject var store: EmojiArtDocumentStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink (destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(Text(self.store.name(for: document)))) {
                            Text(self.store.name(for: document))
                        }
                }
            }
            .navigationBarTitle(Text("Emoji Art"))
            .navigationBarItems(leading: Button(action: {
                self.store.addDocument()
            }, label: {
                Image(systemName: "bag.badge.plus")
            }))
        }
    }
}

struct EmojiArtDocumentStoreView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentStoreView(store: EmojiArtDocumentStore())
    }
}
