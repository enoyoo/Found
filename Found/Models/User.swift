//
//  User.swift
//  Found
//
//  Created by Eno Yoo on 12/1/25.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var username = ""
    var email = ""
    var userID = ""
    
}

extension User {
    static var preview: User {
        let newItem = User(id: "eno.yoo@bc.edu", username: "eno.yoo", email: "eno.yoo@bc.edu", userID: "")
        return newItem
    }
}
