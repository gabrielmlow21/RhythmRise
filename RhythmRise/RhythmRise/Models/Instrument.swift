//
//  Instrument.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/25/24.
//

import Foundation

enum Instrument: Codable {
    case piano
    case guitar
    case violin
    case drums
    case saxophone
    case flute
    case cello
    case trumpet
    case clarinet
    case harmonica
    
    var description: String {
        switch self {
        case .piano: return "Piano"
        case .guitar: return "Guitar"
        case .violin: return "Violin"
        case .drums: return "Drums"
        case .saxophone: return "Saxophone"
        case .flute: return "Flute"
        case .cello: return "Cello"
        case .trumpet: return "Trumpet"
        case .clarinet: return "Clarinet"
        case .harmonica: return "Harmonica"
        }
    }
}
