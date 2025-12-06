//
//  Message.swift
//  Found
//
//  Created by Eno Yoo on 12/5/25.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var senderID: String
    var time: Date
}
