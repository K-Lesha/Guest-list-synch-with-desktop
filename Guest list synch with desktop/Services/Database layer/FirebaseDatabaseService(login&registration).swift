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

protocol FirebaseDatabaseProtocol: OnlineEventsDatabaseProtocol, OfflineEventsDatabaseProtocol {
    
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
}


enum FirebaseDatabaseError: String, Error {
    case error
}


class FirebaseDatabase: FirebaseDatabaseProtocol {
    //MARK: -PROPERTIES
    internal let database = Database.database(url: "https://guest-list-295cc-default-rtdb.europe-west1.firebasedatabase.app/").reference().child("users")
    internal var lastDatabaseSnapshot: DataSnapshot? = nil
    internal let firebase = Auth.auth()
    internal let operationQueue = OperationQueue()
    
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
    // MARK: -Supporting service methods
    internal func updateDatabaseSnapshot() {
        guard firebase.currentUser != nil else {
            print("can't update database, user == nil")
            return
        }
        self.database.queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            self.lastDatabaseSnapshot = snapshot
            FirebaseDatabaseSemaphore.shared.signal()
        }
        FirebaseDatabaseSemaphore.shared.wait()
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