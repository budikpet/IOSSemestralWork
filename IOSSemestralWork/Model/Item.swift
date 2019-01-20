//
//  Item.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

enum ItemType: String {
    case folder
    case myRssFeed
    case myRssItem
}

class Item: Object {
    @objc dynamic var title: String = "SomeItem"
    
    /**
     The ItemType enum can't be saved directly using Realm. Variable savedType is saved as a String but type variable is used everywhere else.
     */
    @objc private dynamic var savedType: String = ItemType.myRssItem.rawValue
    var type: ItemType {
        get {
            return ItemType(rawValue: savedType)!
        }
        
        set {
            savedType = newValue.rawValue
        }
    }
    
    convenience init(with title: String, type: ItemType) {
        self.init()
        self.title = title
        self.type = type
    }
}
