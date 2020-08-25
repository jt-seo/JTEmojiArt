//
//  EmojiArtExtensions.swift
//  JTEmojiArt
//
//  Created by JT3 on 2020/08/25.
//  Copyright © 2020 JT. All rights reserved.
//

import Foundation

extension URL {
    var imageURL: URL? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        
        if let queryItems = components.percentEncodedQueryItems {
            for query in queryItems {
                if query.name == "imgurl", let url = query.value {
                    return URL(string: url)
                }
            }
        }
        return self
    }
}
