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
}


enum FirebaseDatabaseError: String, Error {
    case error
}


class FirebaseDatabase: FirebaseDatabaseProtocol {
    private let database = Database.database(url: "https://guest-list-295cc-default-rtdb.europe-west1.firebasedatabase.app/").reference().child("users")
    private var lastDatabaseSnapshot: DataSnapshot? = nil
    private let firebase = Auth.auth()


    //MARK: - FIREBASE DATABASE METHODS
    private func updateDatabaseSnapshot(completion: @escaping () -> ()) {
        guard firebase.currentUser != nil else {
            return
        }
        database.queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            self.lastDatabaseSnapshot = snapshot
            completion()
        }
        
    }
    func saveNewFirebaseUserToTheDatabase(userUID: String,
                                          email: String,
                                          name: String,
                                          surname: String,
                                          agency: String,
                                          userTypeRawValue: Int,
                                          signInProvider: String,
                                          demoEventID: String,
                                          completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        self.updateDatabaseSnapshot() {
            //find user in database
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {return}
            let usersDictionary = userDatabaseSnapshot.value as? NSDictionary
            let userData = usersDictionary?.object(forKey: userUID) as? NSDictionary
            
            
            if userData != nil {
                self.setupUserToTheApp(user: self.firebase.currentUser!)
            } else {
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
                                                                "registrationFinished": "true"])
                self.setupUserToTheApp(user: self.firebase.currentUser!)
            }
        }
    }
    func firstStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                        name: String,
                                                        email: String,
                                                        signInProvider: String,
                                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        self.updateDatabaseSnapshot() {
            //find user in database
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {return}
            let usersDictionary = userDatabaseSnapshot.value as? NSDictionary
            let userData = usersDictionary?.object(forKey: userUID) as? NSDictionary
            
            if userData != nil {
                self.setupUserToTheApp(user: self.firebase.currentUser!)
            } else {
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
                    if error != nil {
                        completion(.failure(.error))
                    }
                    completion(.success("success"))
                }
            }
        }
    }
    
    func finishStepSavingFacebookGoogleUserToTheDatabase(userUID: String,
                                                         surname: String,
                                                         userTypeRawValue: Int,
                                                         demoEventID: String,
                                                         agency: String,
                                                         completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        self.database.child(userUID).updateChildValues(["surname": surname,
                                                        "agency": agency,
                                                        "eventsIdList": [demoEventID] as! NSArray,
                                                        "userTypeRawValue": String(userTypeRawValue),
                                                        "registrationFinished": "true"]) { error, databasereference in
            if error != nil {
                completion(.failure(.error))
            }
            completion(.success("success"))
        }
    }
    
    func setupUserToTheApp(user: User) {
        //find user in database
        self.updateDatabaseSnapshot {
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {return}
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
            FirebaseService.logginnedUser = user
            EventsListSemaphore.shared.signal()
        }
    }
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
    func updateValues(userUID: String,
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
