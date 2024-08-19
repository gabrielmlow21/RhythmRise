//
//  Activity.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/16/24.
//

import Foundation

class Activity: NSObject, Codable {
    
    var id: String = ""
    var activity_description: String = ""  // description as variable name cannot be used
    var equipment: Equipment?
    var post_time: String = ""
    var timestamp: Double?
    var elapsed_time: Double?
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case activity_description
        case equipment
        case timestamp
        case elapsed_time
    }
}
