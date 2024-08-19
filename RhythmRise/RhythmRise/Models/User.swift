//
//  User.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/2/24.
//

import Foundation

class User: NSObject, Codable {

    var bio: String = ""
    var location: String = ""
    var followers: [User] = []
    var following: [User] = []
    var profilePicture: String = ""
    var username: String = ""

    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case bio
        case location
        case followers
        case following
        case profilePicture
        case username
    }
}
