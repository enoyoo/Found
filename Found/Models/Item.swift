//
//  Item.swift
//  Found
//
//  Created by Eno Yoo on 11/26/25.
//

import Foundation
import FirebaseFirestore

enum Category: String, CaseIterable, Codable {
    case lost, found
}

struct Item: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name = ""
    var time = Date.now
    var itemLocation = ""
    var itemAddress = ""
    var latitude = 0.0
    var longitude = 0.0
    var notes = ""
    var category = Category.lost.rawValue
    var resolved = false
    var userID = ""
    var postedOn = Date()
    
    
}

extension Item {
    static var preview: Item {
        let newItem = Item(id: "1", name: "Swift", itemLocation: "Fulton Hall", latitude: 42.3601, longitude: -71.0589, notes: "Swifty", category: "found", resolved: false, userID: "eno.yoo@bc.edu")
        return newItem
    }
}
