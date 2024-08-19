//
//  DatabaseProtocol.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/1/24.
//

import Foundation
import UIKit

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case equipment
    case activities
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onUserDetailsChange(change: DatabaseChange, user: User)
    func onEquipmentsChange(change: DatabaseChange, equipments: [Equipment])
    func onActivitiesChange(change: DatabaseChange, activities: [Activity])
}


protocol DatabaseProtocol: AnyObject {
    
    var userDetails: User? {get}
    var equipments: [Equipment] {get}
    
    func createAccount(email: String, password: String, username: String) async throws
    func login(email: String, password: String) async throws
    
    func updateUserBioAndLocation(bio: String, location: String, completion: @escaping (Bool) -> Void)
    func updateUserImage(newImage: UIImage?, completion: @escaping (Bool) -> Void)
    
    func saveEquipment(instrument: String, brand: String, model: String, completion: @escaping (Bool) -> Void)
    func removeEquipment(equipment: Equipment)
    
    func saveActivity(elapsedTime: TimeInterval, equipment: Equipment, description: String?, completion: @escaping (Bool) -> Void)
    func updateActivity(updatedActivity: Activity, completion: @escaping (Bool) -> Void)
    func removeActivity(activity: Activity, completion: @escaping (Bool) -> Void)
    func getActivitiesFromLast7Days(completion: @escaping ([Activity]?, Error?) -> Void)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}

