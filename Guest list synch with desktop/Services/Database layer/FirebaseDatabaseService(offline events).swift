//
//  FirebaseDatabaseService(offline events).swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 21.11.2022.
//

import Foundation

protocol OfflineEventsDatabaseProtocol {
    func setOfflineEventToDatabase(event: EventEntity, completion: @escaping (Result<EventEntity, FirebaseError>) -> ())
    func readOfflineEventsFromDatabase(completion: @escaping (Result<NSDictionary, FirebaseError>) -> ())
    func readOneOfflineEventFromDatabase(offlineEventID: String, completion: @escaping (Result<NSDictionary, FirebaseError>) -> ())
}

extension FirebaseDatabase {
    
    func setOfflineEventToDatabase(event: EventEntity, completion: @escaping (Result<EventEntity, FirebaseError>) -> ()) {
        
        guard let databaseSnapshot = self.lastDatabaseSnapshot,
              let userUID = FirebaseService.logginnedUser?.uid,
              let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
              let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary
        else {
            completion(.failure(.databaseError))
            return
        }

        
        let guestEntitiesArray = event.guestsEntites
        let guestsDict = GuestEntity.createGuestsDictFromArray(guestEntitiesArray)

        let newDictionaryEvent: Dictionary<String, Any> = [event.eventID: ["eventName": event.eventName,
                                                                "eventClient": event.eventClient,
                                                                "eventVenue": event.eventVenue,
                                                                "eventDate": event.eventDate,
                                                                "eventTime": event.eventTime,
                                                                "eventID": event.eventID,
                                                                "initedByUserUID": event.initedByUserUID,
                                                                "initedByUserName": event.initedByUserName,
                                                                "isOnline": event.isOnline,
                                                                "guestEntities": guestsDict]]
        

        var dictionatyToUpload = newDictionaryEvent
        
        if let existingOfflineEventsDicts = userData.object(forKey: "offlineEvents") as? Dictionary<String, Any> {
            dictionatyToUpload = existingOfflineEventsDicts
            dictionatyToUpload[event.eventID] = newDictionaryEvent[event.eventID]
        }
        
        self.database.child(userUID).updateChildValues(["offlineEvents": dictionatyToUpload as NSDictionary]) { error, databaseReference in
            if error != nil {
                completion(.failure(.databaseError))
            }
            completion(.success(event))
        }
    }
    
    
    func readOfflineEventsFromDatabase(completion: @escaping (Result<NSDictionary, FirebaseError>) -> ()) {
        let operation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        operation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot,
                  let userUID = FirebaseService.logginnedUser?.uid,
                  let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
                  let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary,
                  let offlineEventsArray = userData.object(forKey: "offlineEvents") as? NSDictionary
            else {
                completion(.failure(.databaseError))
                return
            }
            completion(.success(offlineEventsArray))
        }
        operationQueue.addOperation(operation)
    }
    func readOneOfflineEventFromDatabase(offlineEventID: String, completion: @escaping (Result<NSDictionary, FirebaseError>) -> ()) {
        let operation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        operation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot,
                  let userUID = FirebaseService.logginnedUser?.uid,
                  let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
                  let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary,
                  let offlineEventsArray = userData.object(forKey: "offlineEvents") as? NSDictionary,
                  let offlineEvent = offlineEventsArray.object(forKey: offlineEventID) as? NSDictionary
            else {
                completion(.failure(.databaseError))
                return
            }
            completion(.success(offlineEvent))
        }
        operationQueue.addOperation(operation)
    }
}
