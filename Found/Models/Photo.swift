//
//  Photo.swift
//  Found
//
//  Created by Eno Yoo on 12/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = ""
    var userID: String = ""
    var postedOn = Date()
    
    
    
    init(id: String? = nil, imageURLString: String = "", userID: String = "", postedOn: Date = Date()) {
        self.id = id
        self.imageURLString = imageURLString
        self.userID = userID
        self.postedOn = postedOn
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/e/e6/Coin_video_game.png",
            userID: "eno.yoo@bc.edu",
            postedOn: Date()
        )
        return newPhoto
    }
}
