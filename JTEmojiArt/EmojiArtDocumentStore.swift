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
    @Published private(set) var documentNames = [EmojiArtDocument: String]()
    var documents: [EmojiArtDocument] {
        documentNames.keys.sorted {
            documentNames[$0]! < documentNames[$1]!
        }
    }
    
    var autoSaveCancellable: AnyCancellable?
    
    var name: String
    init(named name: String = "EmojiArt") {
        let emojiArtDocmentStoreKey = "EmojiArtDocumentStore.\(name)"
        self.name = name
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: emojiArtDocmentStoreKey))
        print("load count: \(documentNames.count)")
        autoSaveCancellable = $documentNames.sink { store in
            print("save count: \(store.count)")
            UserDefaults.standard.set(store.asPropertyList, forKey: emojiArtDocmentStoreKey)
        }
    }

    var directory: URL?
    init(directory: URL) {
        self.directory = directory
        self.name = directory.lastPathComponent
        
        do {
            let documents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            for document in documents {
                let emojiArtDocument = EmojiArtDocument(url: directory.appendingPathComponent(document))
                self.documentNames[emojiArtDocument] = document
            }
        } catch {
            print("Couldn't read documents at \(directory.path): \(error.localizedDescription)")
        }
    }
    
    func addDocument(named name: String = "Untitled") {
        let uniqueName = name.uniqued(withRespectTo: documentNames.values)
        let document: EmojiArtDocument
        if let url = directory?.appendingPathComponent(uniqueName) {
            document = EmojiArtDocument(url: url)
        } else {
            document = EmojiArtDocument()
        }
        documentNames[document] = uniqueName
    }
    
    func removeDocument(_ document: EmojiArtDocument) {
        if let name = documentNames[document], let url = directory?.appendingPathComponent(name) {
            try? FileManager.default.removeItem(at: url)
        }
        documentNames.removeValue(forKey: document)
    }
    
    func changeDocumentName(for document: EmojiArtDocument, to name: String) {
        if let url = directory?.appendingPathComponent(name) {
            if !documentNames.values.contains(name),
               let oldName = documentNames[document],
               let oldUrl = directory?.appendingPathComponent(oldName) {
                print("old: \(oldName), new: \(name)")
                try? FileManager.default.moveItem(at: oldUrl, to: url)
                documentNames[document] = name
            } else {
                print("duplicated name")
            }
        } else {
            documentNames[document] = name
        }
    }
    
    func name(for document: EmojiArtDocument) -> String {
        documentNames[document] ?? ""
    }
}

extension Dictionary where Key == EmojiArtDocument, Value == String {
    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
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
