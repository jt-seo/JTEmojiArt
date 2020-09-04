//
//  EmojiArtDocumentStore.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/09/03.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

class EmojiArtDocumentStore: ObservableObject {
    @Published private(set) var documents = [EmojiArtDocument]()
    private(set) var names = [EmojiArtDocument: String]()
    
    func addDocument(named name: String = "Untitled") {
        let document = EmojiArtDocument()
        documents.append(document)
        names[document] = name
    }
    
    func removeDocument(_ document: EmojiArtDocument) {
        names.removeValue(forKey: document)
    }
    
    func changeDocumentName(for document: EmojiArtDocument, to name: String) {
        names[document] = name
    }
    
    func name(for document: EmojiArtDocument) -> String {
        names[document] ?? ""
    }
}

