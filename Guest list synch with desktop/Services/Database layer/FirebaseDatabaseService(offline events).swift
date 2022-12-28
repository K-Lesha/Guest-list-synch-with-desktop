//
//  FirebaseDatabaseService(offline events).swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 21.11.2022.
//

import Foundation

protocol OfflineEventsDatabaseProtocol {
    func addOfflineEventToUserDatabase(event: EventEntity, completion: @escaping (Result<EventEntity, FirebaseError>) -> ())
    func readOfflineEventsFromDatabase(completion: @escaping (Result<NSDictionary, FirebaseError>) -> ())
    func readOneOfflineEventFromDatabase(offlineEventID: String, completion: @escaping (Result<NSDictionary, FirebaseError>) -> ())
    func deleteOfflineEventInDatabase(eventID: String,
                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func readOneGuestDataFromDatabase(eventID: String,
                                      guestID: String,
                                      completion: @escaping (Result<GuestEntity, SheetsError>) -> ())
    func updateOneGuestData(eventID: String, guestID: String, data: NSDictionary, completion: @escaping (String) -> ())
    func updateOnePropertyInGuestData(eventID: String, guestID: String, key: String, value: String, completion: @escaping (String) -> ())
    func removeOneGuestFromDatabase(eventID: String, guestID: String, completion: @escaping (String) -> ())
}

extension FirebaseDatabase {
    func addOfflineEventToUserDatabase(event: EventEntity, completion: @escaping (Result<EventEntity, FirebaseError>) -> ()) {
        guard let databaseSnapshot = self.lastDatabaseSnapshot,
              let userUID = FirebaseService.logginnedUser?.uid,
              let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
              let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary
        else {
            completion(.failure(.databaseError))
            return
        }
        let guestsDict = GuestEntity.createGuestsDictFrom(event.guestsEntites)
        let newDictionaryEvent: Dictionary<String, Any> = [event.eventID: ["name": event.name,
                                                                           "client": event.client,
                                                                           "venue": event.venue,
                                                                           "date": event.date,
                                                                           "time": event.time,
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
    public func deleteOfflineEventInDatabase(eventID: String,
                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
            guard let userUID = FirebaseService.logginnedUser?.uid
            else {
                return
            }
        self.database.child(userUID).child("offlineEvents").child(eventID).removeValue() {_,_ in
            completion(.success("ok"))
        }
    }
    public func readOneGuestDataFromDatabase(eventID: String, guestID: String, completion: @escaping (Result<GuestEntity, SheetsError>) -> ()) {
        let operation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        operation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot,
                  let userUID = FirebaseService.logginnedUser?.uid,
                  let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
                  let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary,
                  let offlineEventsArray = userData.object(forKey: "offlineEvents") as? NSDictionary,
                  let offlineEvent = offlineEventsArray.object(forKey: eventID) as? NSDictionary,
                  let allTheGuestsData = offlineEvent.object(forKey: "guestEntities") as? NSDictionary,
                  let oneGuestData = allTheGuestsData.object(forKey: guestID) as? NSDictionary
            else {
                completion(.failure(.error))
                return
            }
            let oneGuest = GuestEntity.createOneGuestFrom(oneGuestData)
            DispatchQueue.main.async {
                completion(.success(oneGuest))
            }
        }
        operationQueue.addOperation(operation)
    }
    public func updateOneGuestData(eventID: String, guestID: String, data: NSDictionary, completion: @escaping (String) -> ()) {
        guard let userUID = FirebaseService.logginnedUser?.uid
        else {
            return
        }
        self.database.child(userUID).child("offlineEvents").child(eventID).child("guestEntities").updateChildValues([guestID: data]) {error, databaseReference in
            guard error == nil else { return }
            completion("ok")
        }
    }

    public func updateOnePropertyInGuestData(eventID: String, guestID: String, key: String, value: String, completion: @escaping (String) -> ()) {
        guard let userUID = FirebaseService.logginnedUser?.uid
        else {
            return
        }
        self.database.child(userUID).child("offlineEvents").child(eventID).child("guestEntities").child(guestID).updateChildValues([key: value]) {error, databaseReference in
            guard error == nil else { return }
            completion("ok")
        }
    }
    public func removeOneGuestFromDatabase(eventID: String, guestID: String, completion: @escaping (String) -> ()) {
        guard let userUID = FirebaseService.logginnedUser?.uid
        else {
            return
        }
        self.database.child(userUID).child("offlineEvents").child(eventID).child("guestEntities").child(guestID).removeValue() {error, databaseReference in
            guard error == nil else { return }
            completion("ok")
        }
    }

}
