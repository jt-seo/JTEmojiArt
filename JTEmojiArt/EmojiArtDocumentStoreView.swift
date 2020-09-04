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
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink (destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(Text(self.store.name(for: document)))) {
                            EditableText(isEditing: self.editMode != EditMode.inactive, text: self.store.name(for: document)) { name in
                                self.store.changeDocumentName(for: document, to: name)
                            }
                        }
                }
                .onDelete { indexSet in // Swipe from right to left will invoke onDelete.
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
            }
            .navigationBarTitle(Text("Emoji Art"))
            .navigationBarItems(
                leading: Button(action: {
                        self.store.addDocument()
                    }, label: {
                        Image(systemName: "bag.badge.plus")
                    }),
                trailing: EditButton()
            )
            .environment(\.editMode, self.$editMode)
        }
    }
}

struct EmojiArtDocumentStoreView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentStoreView(store: EmojiArtDocumentStore())
    }
}
