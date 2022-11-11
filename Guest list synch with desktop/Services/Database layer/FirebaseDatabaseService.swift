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

    //MARK: -Public service methods
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
    public func setupUserFromDatabaseToTheApp(user: User, completion: @escaping () -> ()) {
        let setupUserOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        setupUserOperation.completionBlock = {
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {
                print("userDatabaseSnapshot == nil")
                return}
            let usersDictionary = userDatabaseSnapshot.value as? NSDictionary
            let userData = usersDictionary?.object(forKey: user.uid) as? NSDictionary
            // find all the userData in Snapshot
            let payedEvents = userData?.object(forKey: "payedEvents") as! Int
            let eventsIdList = userData?.object(forKey: "eventsIdList") as! Array<String>
            let accessLevelString = userData?.object(forKey: "userTypeRawValue") as! String
            let accessLevelInt: Int = Int(accessLevelString) ?? 4
            let accessLevel = UserTypes(rawValue: accessLevelInt)!
            let coorganizersUIDs = (userData?.object(forKey: "coorganizersUIDs") as? [String])
            let coorganizers = self.initSupportingUsers(uids: coorganizersUIDs)
            let headOrganizersUIDs = userData?.object(forKey: "headOrganizersUIDs") as? [String]
            let headOrganizers = self.initSupportingUsers(uids: headOrganizersUIDs)
            let hostessesUIDs = userData?.object(forKey: "hostessesUIDs") as? [String]
            let hostesses = self.initSupportingUsers(uids: hostessesUIDs)
            
            let delegatedEventIdList = self.initDelegatedEvents(users: [coorganizers, headOrganizers, hostesses])
            
            let name = userData?.object(forKey: "name") as! String
            let surname = userData?.object(forKey: "surname") as! String
            let email = userData?.object(forKey: "email") as! String
            let active = userData?.object(forKey: "active") as! String
            let agency = userData?.object(forKey: "agency") as! String
            let avatarLinkString = userData?.object(forKey: "avatarLinkString") as! String
            let registrationDate = userData?.object(forKey: "registrationDate") as! String
            let signInProvider = userData?.object(forKey: "signInProvider") as! String
            //create the userEntity
            let user = UserEntity(uid: user.uid,
                                  payedEvents: payedEvents,
                                  eventsIdList: eventsIdList,
                                  delegatedEventIdList: delegatedEventIdList,
                                  accessLevel: accessLevel,
                                  coorganizers: coorganizers,
                                  headOrganizers: headOrganizers,
                                  hostesses: hostesses,
                                  name: name,
                                  surname: surname,
                                  email: email,
                                  active: active.bool!,
                                  agency: agency,
                                  avatarLinkString: avatarLinkString,
                                  registrationDate: registrationDate,
                                  signInProvider: signInProvider)
            //set the user to app
            FirebaseService.logginnedUser = user
            DispatchQueue.main.async {
                completion()
            }
        }
        operationQueue.addOperation(setupUserOperation)
    }
    // MARK: -Private service methods
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
    private func initSupportingUsers(uids: [String]?) -> [SupportingUserEntity]? {
        return nil
    }
    private func initDelegatedEvents(users: [[SupportingUserEntity]?]) -> [String]? {
        return nil
    }
    func deleteUserEntityFromApp() {
        
    }
    func deleteUserEntityFromDatabase() {

    }
    func getAllTheEventsFromTheDatabase() {

    }
    private func updateValuesinDatabase(userUID: String,
                      key: String,
                      value: String,
                      completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        self.database.child(userUID).updateChildValues([key: value]) { error, databaseReference in
            if error != nil {
                completion(.failure(.error))
            }
            completion(.success("success"))
        }
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
