//
//  CategoryDataSourceBuilder.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct CategoryDataSourceBuilder {

    static func build() -> [Category] {
        return [
            Category(name: "arts"),
            Category(name: "automobiles"),
            Category(name: "books"),
            Category(name: "business"),
            Category(name: "fashion"),
            Category(name: "food"),
            Category(name: "health"),
            Category(name: "movies"),
            Category(name: "national"),
            Category(name: "opinion"),
            Category(name: "politics"),
            Category(name: "realestate"),
            Category(name: "science"),
            Category(name: "sports"),
            Category(name: "technology"),
            Category(name: "theater"),
            Category(name: "travel"),
            Category(name: "world")
        ]
    }
}
