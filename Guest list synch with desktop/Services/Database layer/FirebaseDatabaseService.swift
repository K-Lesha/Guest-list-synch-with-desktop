//
//  FirebaseDatabase.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore

protocol FirebaseDatabaseProtocol {
    
    func saveNewFirebaseUserToTheDatabase(userUID: String,
                                          email: String,
                                          name: String,
                                          surname: String,
                                          agency: String,
                                          userTypeRawValue: Int,
                                          signInProvider: String,
                                          demoEventID: String,
                                          completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func firstStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                        name: String,
                                                        email: String,
                                                        signInProvider: String,
                                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func finishStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                         surname: String,
                                                         userTypeRawValue: Int,
                                                         demoEventID: String,
                                                         agency: String,
                                                         completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func setupUserFromDatabaseToTheApp(user: User, completion: @escaping () -> ())
    func updateUserData(completion: @escaping () -> ())
    func setNewEventIDInDatabase(eventID: [String],
                      completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func deleteEventIDInDatabase(eventID: String,
                                 completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
}


enum FirebaseDatabaseError: String, Error {
    case error
}


class FirebaseDatabase: FirebaseDatabaseProtocol {
    //MARK: -PROPERTIES
    private let database = Database.database(url: "https://guest-list-295cc-default-rtdb.europe-west1.firebasedatabase.app/").reference().child("users")
    private var lastDatabaseSnapshot: DataSnapshot? = nil
    private let firebase = Auth.auth()
    private let operationQueue = OperationQueue()

    //MARK: -User registration methods
    public func saveNewFirebaseUserToTheDatabase(userUID: String,
                                                 email: String,
                                                 name: String,
                                                 surname: String,
                                                 agency: String,
                                                 userTypeRawValue: Int,
                                                 signInProvider: String,
                                                 demoEventID: String,
                                                 completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let addUserToDatabaseOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        addUserToDatabaseOperation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot else {return}
            let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary
            let userData = allUsersDataDictionary?.object(forKey: userUID) as? NSDictionary
            
            guard userData == nil else {
                self.setupUserFromDatabaseToTheApp(user: self.firebase.currentUser!) {
                    completion(.success("ok"))
                }
                return
            }
            self.database.child(userUID).updateChildValues(["payedEvents": 0,
                                                            "eventsIdList": [demoEventID] as! NSArray,
                                                            "userTypeRawValue": userTypeRawValue,
                                                            "coorganizersUIDs": [""] as! NSArray,
                                                            "headOrganizersUIDs": [""] as! NSArray,
                                                            "hostessesUIDs": [""] as! NSArray,
                                                            "name": name,
                                                            "surname": surname,
                                                            "email": email,
                                                            "active": "true",
                                                            "agency": "noagency",
                                                            "avatarLinkString": "",
                                                            "registrationDate": Date().formatted(date: .complete, time: .complete),
                                                            "signInProvider": signInProvider,
                                                            "registrationFinished": "true"]) { error, databaseReference in
                guard error != nil else {
                    completion(.failure(.error))
                    return
                }
                
            }
        }
        let setupUserOperation = BlockOperation {
            self.setupUserFromDatabaseToTheApp(user: self.firebase.currentUser!) {
                completion(.success("ok"))
            }
        }
        operationQueue.addOperation(addUserToDatabaseOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
        operationQueue.addOperation(setupUserOperation)
    }
    public func firstStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                        name: String,
                                                        email: String,
                                                        signInProvider: String,
                                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let addFirstDataPartOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        addFirstDataPartOperation.completionBlock = {
            guard let databaseSnapshot = self.lastDatabaseSnapshot else {return}
            let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary
            let userData = allUsersDataDictionary?.object(forKey: userUID) as? NSDictionary
            
            guard userData == nil else {
                self.setupUserFromDatabaseToTheApp(user: self.firebase.currentUser!) {
                    completion(.success("ok"))
                }
                return
            }
            self.database.child(userUID).updateChildValues(["payedEvents": 0,
                                                            "eventsIdList": [""] as! NSArray,
                                                            "userTypeRawValue": "",
                                                            "coorganizersUIDs": [""] as! NSArray,
                                                            "headOrganizersUIDs": [""] as! NSArray,
                                                            "hostessesUIDs": [""] as! NSArray,
                                                            "name": name,
                                                            "surname": "",
                                                            "email": email,
                                                            "active": "true",
                                                            "agency": "",
                                                            "avatarLinkString": "",
                                                            "registrationDate": Date().formatted(date: .complete, time: .complete),
                                                            "signInProvider": signInProvider,
                                                            "registrationFinished": "false"]) {error, databaseReference in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
                completion(.success("success"))
            }
        }
        operationQueue.addOperation(addFirstDataPartOperation)
    }
    public func finishStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                         surname: String,
                                                         userTypeRawValue: Int,
                                                         demoEventID: String,
                                                         agency: String,
                                                         completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let addSecondDataPartOperation = BlockOperation {
            self.database.child(userUID).updateChildValues(["surname": surname,
                                                            "agency": agency,
                                                            "eventsIdList": [demoEventID] as! NSArray,
                                                            "userTypeRawValue": String(userTypeRawValue),
                                                            "registrationFinished": "true"]) { error, databasereference in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
            }
        }
        let setupUserOperation = BlockOperation {
            self.setupUserFromDatabaseToTheApp(user: self.firebase.currentUser!) {
                completion(.success("ok"))
            }
        }
        operationQueue.addOperation(addSecondDataPartOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
        operationQueue.addOperation(setupUserOperation)
        
    }
    //MARK: -Setting up user data from database to the app
    public func setupUserFromDatabaseToTheApp(user: User, completion: @escaping () -> ()) {
        let setupUserOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        setupUserOperation.completionBlock = {
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {
                print("userDatabaseSnapshot == nil")
                return}
            let usersDictionary = userDatabaseSnapshot.value as? NSDictionary
            let user = UserEntity.createUserEntityWithData(usersDictionary: usersDictionary, userUID: user.uid)
            //set the user to app
            FirebaseService.logginnedUser = user
            DispatchQueue.main.async {
                completion()
            }
        }
        operationQueue.addOperation(setupUserOperation)
    }
    func updateUserData(completion: @escaping () -> ()) {
        let setupUserOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        setupUserOperation.completionBlock = {
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot,
                  let userUID = FirebaseService.logginnedUser?.uid
            else {
                print("userDatabaseSnapshot == nil")
                return
            }
            let usersDictionary = userDatabaseSnapshot.value as? NSDictionary
            let user = UserEntity.createUserEntityWithData(usersDictionary: usersDictionary, userUID: userUID)
            //set the user to app
            FirebaseService.logginnedUser = user
            DispatchQueue.main.async {
                completion()
            }
        }
        operationQueue.addOperation(setupUserOperation)
    }
    
    //MARK: - Application methods
    public func setNewEventIDInDatabase(eventID: [String],
                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        guard let databaseSnapshot = self.lastDatabaseSnapshot,
              let userUID = FirebaseService.logginnedUser?.uid,
              let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary,
              let userData = allUsersDataDictionary.object(forKey: userUID) as? NSDictionary
        else {
            return
        }

        var existingEvents = Array<String>()
        if let existingEventsInDatabase = userData.object(forKey: "eventsIdList") as? Array<String> {
            existingEvents = existingEventsInDatabase
        }
        let newEventsList = existingEvents + eventID
        
        self.database.child(userUID).updateChildValues(["eventsIdList": newEventsList as NSArray]) { error, databaseReference in
            if error != nil {
                completion(.failure(.error))
            }
            completion(.success("success"))
        }
    }
    public func deleteEventIDInDatabase(eventID: String,
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
            
            let existingEvents = userData?.object(forKey: "eventsIdList") as! Array<String>
            let newEventsList = existingEvents.filter { $0 !=  eventID }
            
            self.database.child(userUID).updateChildValues(["eventsIdList": newEventsList as NSArray]) { error, databaseReference in
                if error != nil {
                    completion(.failure(.error))
                }
                completion(.success("success"))
            }
        }
        operationQueue.addOperation(operation)
    }

    // MARK: -Supporting service methods
    private func updateDatabaseSnapshot() {
        guard firebase.currentUser != nil else {
            print("updateDatabaseSnapshot error")
            return
        }
        self.database.queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            self.lastDatabaseSnapshot = snapshot
            FirebaseDatabaseSemaphore.shared.signal()
        }
        FirebaseDatabaseSemaphore.shared.wait()
    }
    //MARK: -Future methods
    func getAllTheEventsFromTheDatabase() {

    }
}


extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            return nil
        }
    }
}
