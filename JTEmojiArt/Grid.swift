//
//  Grid.swift
//  Memorize
//
//  Created by JT3 on 2020/08/18.
//  Copyright © 2020 JT2. All rights reserved.
//

import SwiftUI

struct Grid<Item, ID, ItemView>: View where ID: Hashable, ItemView: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView
    var id: KeyPath<Item, ID>
    
    init (_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
        self.id = id
    }
    var body: some View {
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    private func body(for layout: GridLayout) -> some View {
        ForEach (items, id: id) { item in
            self.body(for: item, layout: layout)
        }
    }
    
    private func body(for item: Item, layout: GridLayout) -> some View {
        let index = items.firstIndex (where: { $0[keyPath: id] == item[keyPath: id] })
        return viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
            .position(layout.location(ofItemAt: index!))
    }
}

extension Grid where Item: Identifiable, ID == Item.ID {
    init (_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}
