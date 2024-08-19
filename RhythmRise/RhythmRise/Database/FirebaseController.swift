//
//  FirebaseController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/1/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage


class FirebaseController: NSObject, DatabaseProtocol {
    
    var authController: Auth
    var database: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var currentUser: FirebaseAuth.User?
    var currentUsername: String?
    var userDocumentRef: DocumentReference?
    var userDetails: User?

    var userEquipmentsCollectionRef: CollectionReference?
    var equipments: [Equipment] = []
    
    var userActivitiesCollectionRef: CollectionReference?
    var personalActivities: [Activity] = []
    
    var followingActivities: [Activity] = []
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        equipments = [Equipment]()
        personalActivities = [Activity]()
        super.init()
    }
    
    
    func addListener(listener: DatabaseListener) {
        // Add the listener to the listeners property
        listeners.addDelegate(listener)
            
        if listener.listenerType == .user {
            listener.onUserDetailsChange(change: .update, user: userDetails!)
        }
        
        if listener.listenerType == .equipment {
            listener.onEquipmentsChange(change: .update, equipments: equipments)
        }
        
        if listener.listenerType == .activities {
            listener.onActivitiesChange(change: .update, activities: personalActivities)
        }
    }
    
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // USERS
    func setupUserDataListener() {
        userDocumentRef?.addSnapshotListener { [self] documentSnapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = documentSnapshot, documentSnapshot!.exists {
                // Deserialize the document into a User object
                let result = Result {
                    try document.data(as: User.self)
                }
                switch result {
                case .success(let retrievedUser):
                    userDetails = retrievedUser
                    listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.user {
                            listener.onUserDetailsChange(change: .update, user: userDetails!)
                        }
                    }
                case .failure(let error):
                    // A User value could not be initialized from the DocumentSnapshot.
                    print("Error decoding user: \(error)")
                }
            }
        }
    }
    
    func createUsersCollection() {
        let user = User()
        user.username = currentUsername ?? ""
        do {
            try userDocumentRef!.setData(from: user)
        } catch {
            print("Failed to serialize team")
        }
    }
    
    func createAccount(email: String, password: String, username: String) async throws {
        let authDataResult = try await authController.createUser(withEmail: email, password: password)
        currentUser = authDataResult.user
        currentUsername = username
        userDocumentRef = database.collection("users").document(currentUser!.uid)
        createUsersCollection()
        setupUserDataListener()
        setupEquipmentsListener()
        setupActivitiesListener()
    }
    
    func login(email: String, password: String) async throws {
        let authDataResult = try await authController.signIn(withEmail: email, password: password)
        currentUser = authDataResult.user
        userDocumentRef = database.collection("users").document(currentUser!.uid)
        setupUserDataListener()
        setupEquipmentsListener()
        setupActivitiesListener()
    }
    
    func updateUserBioAndLocation(bio: String, location: String, completion: @escaping (Bool) -> Void) {
        userDocumentRef?.updateData(["bio" : bio, "location": location]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(false)
            } else {
                print("Document successfully updated")
                completion(true)
            }
        }
    }
    
    func updateUserImage(newImage: UIImage?, completion: @escaping (Bool) -> Void) {
        // Check if newImage is nil
        guard let newImage = newImage else {
            print("newImage is nil")
            completion(false)
            return
        }

        // 1. Convert the UIImage to Data
        guard let imageData = newImage.jpegData(compressionQuality: 0.75) else {
            print("Error converting image to data")
            completion(false)
            return
        }

        // 2. Create a Storage Reference
        let storageRef = Storage.storage().reference().child("profilePictures/\(UUID().uuidString).jpg")

        // 3. Create Metadata
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        // 4. Upload Data to Firebase Storage
        storageRef.putData(imageData, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(false)
            } else {
                // 5. Once the image is uploaded, retrieve the download URL
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download url: \(error.debugDescription)")
                        completion(false)
                        return
                    }

                    // 6. Then update the Firestore Document with the download URL
                    self.userDocumentRef?.updateData(["profilePicture": downloadURL.absoluteString]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            completion(false)
                        } else {
                            print("Document successfully updated")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
  
    // EQUIPMENTS
    func setupEquipmentsListener() {
        userEquipmentsCollectionRef = userDocumentRef!.collection("equipments")
        userEquipmentsCollectionRef?.addSnapshotListener() { [self]
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            querySnapshot.documentChanges.forEach { (change) in var equipment: Equipment
                do {
                    equipment = try change.document.data(as: Equipment.self)
                    equipment.id = change.document.documentID
                    if change.type == .added {
                        equipments.insert(equipment, at: Int(change.newIndex))
                    } else if change.type == .modified {
                        equipments.remove(at: Int(change.oldIndex))
                        equipments.insert(equipment, at: Int(change.newIndex))
                    } else if change.type == .removed {
                        equipments.remove(at: Int(change.oldIndex))
                    }
                    
                } catch {
                    fatalError("Unable to decode hero: \(error.localizedDescription)")
                }
            }
            listeners.invoke {
                (listener) in if listener.listenerType == ListenerType.equipment {
                    listener.onEquipmentsChange(change: .update, equipments: equipments)
                }
            }
        }
    }
    
    func saveEquipment(instrument: String, brand: String, model: String, completion: @escaping (Bool) -> Void) {
        let newEquipment = Equipment()
        newEquipment.brand = brand
        newEquipment.instrument = instrument
        newEquipment.model = model
        do {
            let _ = try userEquipmentsCollectionRef!.addDocument(from: newEquipment)
            completion(true)
        } catch {
            print("Error creating new equipment: \(error)")
            completion(false)
        }
    }
    
    func removeEquipment(equipment: Equipment) {
        userEquipmentsCollectionRef?.document(equipment.id).delete()
    }


    // ACTIVITIES
    func setupActivitiesListener() {
        userActivitiesCollectionRef = userDocumentRef!.collection("activities")
        userActivitiesCollectionRef?.addSnapshotListener() { [self]
            (querySnapshot, error) in guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            querySnapshot.documentChanges.forEach { (change) in var activity: Activity
                do {
                    activity = try change.document.data(as: Activity.self)
                    activity.id = change.document.documentID
                    if change.type == .added {
                        personalActivities.insert(activity, at: Int(change.newIndex))
                    } else if change.type == .modified {
                        personalActivities.remove(at: Int(change.oldIndex))
                        personalActivities.insert(activity, at: Int(change.newIndex))
                    } else if change.type == .removed {
                        personalActivities.remove(at: Int(change.oldIndex))
                    }
                    
                } catch {
                    fatalError("Unable to decode hero: \(error.localizedDescription)")
                }
            }
            listeners.invoke {
                (listener) in if listener.listenerType == ListenerType.activities {
                    listener.onActivitiesChange(change: .update, activities: personalActivities)
                }
            }
        }
    }
    
    func saveActivity(elapsedTime: TimeInterval, equipment: Equipment, description: String?, completion: @escaping (Bool) -> Void) {
        let newActivity = Activity()
        newActivity.activity_description = description!
        newActivity.equipment = equipment
        newActivity.elapsed_time = elapsedTime
        newActivity.timestamp = Date().timeIntervalSince1970  // get time now
        do {
            let _ = try userActivitiesCollectionRef!.addDocument(from: newActivity)
            completion(true)
        } catch {
            print("Error creating new activity: \(error)")
            completion(false)
        }
    }
    
    // since equipment is a custom Swift type, it needs to be converted before writing to Firestore
    func updateActivity(updatedActivity: Activity, completion: @escaping (Bool) -> Void) {
        do {
            let encoder = Firestore.Encoder()
            let equipmentDictionary = try encoder.encode(updatedActivity.equipment)
            userActivitiesCollectionRef?.document(updatedActivity.id).updateData(["activity_description" : updatedActivity.activity_description, "equipment": equipmentDictionary]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    completion(false)
                } else {
                    print("Document successfully updated")
                    completion(true)
                }
            }
        } catch let error {
            print("Error encoding equipment: \(error)")
            completion(false)
        }
    }
    
    func removeActivity(activity: Activity, completion: @escaping (Bool) -> Void) {
        userActivitiesCollectionRef?.document(activity.id).delete()
    }
    
    // get activities only from the past 7 days
    func getActivitiesFromLast7Days(completion: @escaping ([Activity]?, Error?) -> Void) {
        // Get the timestamp for 7 days ago
        let sevenDaysAgo = Date().addingTimeInterval(-7*24*60*60).timeIntervalSince1970

        // Create a query with a range filter
        let query = userActivitiesCollectionRef!.whereField("timestamp", isGreaterThan: sevenDaysAgo)

        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var pastWeekActivities: [Activity] = []
                for document in querySnapshot!.documents {
                    do {
                        // Convert the Firestore document to an Activity object
                        let activity = try document.data(as: Activity.self)
                        pastWeekActivities.append(activity)
                    } catch {
                        print("Error decoding document: \(error)")
                    }
                }
                completion(pastWeekActivities, nil)
            }
        }
    }
}
