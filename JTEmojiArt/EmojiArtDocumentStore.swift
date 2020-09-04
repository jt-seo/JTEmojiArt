//
//  EmojiArtDocumentStore.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/09/03.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocumentStore: ObservableObject {
    @Published private(set) var documentNames: [EmojiArtDocument: String]
    var documents: [EmojiArtDocument] {
        documentNames.keys.sorted {
            documentNames[$0]! < documentNames[$1]!
        }
    }
    
    var autoSaveCancellable: AnyCancellable?
    
    init() {
        let emojiArtDocmentStoreKey = "EmojiArtDocumentStore"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: emojiArtDocmentStoreKey))
        print("load count: \(documentNames.count)")
        autoSaveCancellable = $documentNames.sink { store in
            print("save count: \(store.count)")
            UserDefaults.standard.set(store.asPropertyList, forKey: emojiArtDocmentStoreKey)
        }
    }
    
    func addDocument(named name: String = "Untitled") {
        documentNames[EmojiArtDocument()] = name
    }
    
    func removeDocument(_ document: EmojiArtDocument) {
        documentNames.removeValue(forKey: document)
    }
    
    func changeDocumentName(for document: EmojiArtDocument, to name: String) {
        documentNames[document] = name
    }
    
    func name(for document: EmojiArtDocument) -> String {
        documentNames[document] ?? ""
    }
}

extension Dictionary where Key == EmojiArtDocument, Value == String {
    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            print(key)
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
    
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtDocument(id: UUID(uuidString: uuid))] = uuidToName[uuid]
        }
    }
}
