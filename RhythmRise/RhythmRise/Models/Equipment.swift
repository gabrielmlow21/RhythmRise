//
//  Equipment.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/25/24.
//

import Foundation


class Equipment: NSObject, Codable {
    
    var id: String = ""
    var brand: String = ""
    var instrument: String = ""
    var model: String = ""
    var seconds_used: Int = 0
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case brand
        case instrument
        case model
        case seconds_used
    }
}
