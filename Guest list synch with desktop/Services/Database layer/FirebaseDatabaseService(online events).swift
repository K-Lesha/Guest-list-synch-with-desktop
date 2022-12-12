//
//  FirebaseDatabaseService(online events).swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 21.11.2022.
//

import Foundation

protocol OnlineEventsDatabaseProtocol {
    func setNewOnlineEventIDInDatabase(eventID: String,
                      completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func deleteOnlineEventIDInDatabase(eventID: String,
                                 completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
}

extension FirebaseDatabase {

    public func setNewOnlineEventIDInDatabase(eventID: String,
                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        guard let databaseSnapshot = self.lastDatabaseSnapshot,
              let userUID = FirebaseService.logginnedUser?.uid,
              let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
              let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary
        else {
            return
        }
        var existingEvents = Array<String>()
        if let existingEventsInDatabase = userData.object(forKey: "onlineEventsIDList") as? Array<String> {
            existingEvents = existingEventsInDatabase
        }
        let newEventsList = existingEvents + [eventID]
        
        self.database.child(userUID).updateChildValues(["onlineEventsIDList": newEventsList as NSArray]) { error, databaseReference in
            if error != nil {
                completion(.failure(.error))
            }
            completion(.success("success"))
        }
    }
    public func deleteOnlineEventIDInDatabase(eventID: String,
                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let operation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        operation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot,
                  let userUID = FirebaseService.logginnedUser?.uid
            else {
                return
            }
            
            let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary
            let userData = allUsersDataDictionary?.object(forKey: userUID) as? NSDictionary
            
            let existingEvents = userData?.object(forKey: "onlineEventsIDList") as! Array<String>
            let newEventsList = existingEvents.filter { $0 != eventID }
            
            self.database.child(userUID).updateChildValues(["onlineEventsIDList": newEventsList as NSArray]) { error, databaseReference in
                if error != nil {
                    completion(.failure(.error))
                }
                completion(.success("success"))
            }
        }
        operationQueue.addOperation(operation)
    }
}
