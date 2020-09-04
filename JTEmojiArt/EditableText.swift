//
//  EditableText.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/09/04.
//  Copyright © 2020 JT. All rights reserved.
//

import SwiftUI

struct EditableText: View {
    var isEditing: Bool
    var text: String
    var onChanged: (String) -> Void
    @State var editableText: String
    
    init(isEditing: Bool, text: String, onChanged: @escaping (String) -> Void) {
        self.isEditing = isEditing
        self.text = text
        self.onChanged = onChanged
        
        _editableText = State(wrappedValue: text)
    }

    var body: some View {
        bodyBuilder()
    }
    
    @ViewBuilder
    func bodyBuilder() -> some View {
        ZStack(alignment: .leading) {
            TextField(text, text: $editableText, onEditingChanged: { began in
                print("editChanging: \(self.editableText)")
                self.callOnChanged(self.editableText)
            })
                .opacity(isEditing ? 1 : 0)
                .disabled(isEditing ? false : true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text(editableText)
                .opacity(isEditing ? 0 : 1)
        }
    }
    
    func callOnChanged(_ text: String) {
        if text != self.text {
            onChanged(text)
        }
    }
}
