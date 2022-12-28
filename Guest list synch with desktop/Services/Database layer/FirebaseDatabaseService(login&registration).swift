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
    
    func saveNewFirebaseUserToTheDatabase(registeringUser: RegisteringUser,
                                          completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func firstStepSavingFacebookGoogleUserToTheDatabase(registeringUser: RegisteringUser,
                                                        completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func finishStepSavingFacebookGoogleUserToTheDatabase(registeringUser: RegisteringUser,
                                                         completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func downloadUserDataToTheApp(userUID: String, completion: @escaping () -> ())
    func updateUserDataInTheApp(completion: @escaping () -> ())
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
    public func saveNewFirebaseUserToTheDatabase(registeringUser: RegisteringUser,
                                                 completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        self.database.child(registeringUser.uid).updateChildValues(["payedEvents": 0,
                                                        "userTypeRawValue": String(registeringUser.userTypeRawValue ?? 3),
                                                        "coorganizersUIDs": [""] as! NSArray,
                                                        "headOrganizersUIDs": [""] as! NSArray,
                                                        "hostessesUIDs": [""] as! NSArray,
                                                        "name": registeringUser.name,
                                                        "surname": registeringUser.surname ?? " ",
                                                        "email": registeringUser.email,
                                                        "active": "true",
                                                        "agency": "noagency",
                                                        "avatarLinkString": "",
                                                        "registrationDate": Date().formatted(date: .complete, time: .complete),
                                                        "signInProvider": registeringUser.signInProvider,
                                                        "registrationFinished": "true"]) { error, databaseReference in
            guard error == nil else {
                completion(.failure(.databaseError))
                return
            }
            self.downloadUserDataToTheApp(userUID: registeringUser.uid) {
                completion(.success(registeringUser))
            }
        }
    }
    
    
    public func firstStepSavingFacebookGoogleUserToTheDatabase(registeringUser: RegisteringUser,
                                                               completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let uploadFirsDataPart = BlockOperation {
            //TODO: перенести этот кусок в checkUserExistingInDatabase()
            self.updateDatabaseSnapshot()
        }
        uploadFirsDataPart.completionBlock = {
            guard !self.checkUserExistingInDatabase(userUID: registeringUser.uid) else {
                self.downloadUserDataToTheApp(userUID: registeringUser.uid) {
                    completion(.success("ok"))
                }
                return
            }
            self.database.child(registeringUser.uid).updateChildValues(["payedEvents": 0,
                                                                        "userTypeRawValue": "",
                                                                        "coorganizersUIDs": [""] as! NSArray,
                                                                        "headOrganizersUIDs": [""] as! NSArray,
                                                                        "hostessesUIDs": [""] as! NSArray,
                                                                        "name": registeringUser.name,
                                                                        "surname": "",
                                                                        "email": registeringUser.email,
                                                                        "active": "true",
                                                                        "agency": "",
                                                                        "avatarLinkString": "",
                                                                        "registrationDate": Date().formatted(date: .complete, time: .complete),
                                                                        "signInProvider": registeringUser.signInProvider,
                                                                        "registrationFinished": "false"]) {error, databaseReference in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
                completion(.success("success"))
            }
        }
        operationQueue.addOperation(uploadFirsDataPart)
    }
    
    public func finishStepSavingFacebookGoogleUserToTheDatabase(registeringUser: RegisteringUser,
                                                                completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        let addSecondDataPartOperation = BlockOperation {
            self.database.child(registeringUser.uid).updateChildValues(["surname": registeringUser.surname ?? "",
                                                                        "agency": registeringUser.agency ?? "",
                                                                        "userTypeRawValue": String(registeringUser.userTypeRawValue ?? 0),
                                                                        "registrationFinished": "true"]) { error, databasereference in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
            }
        }
        let setupUserOperation = BlockOperation {
            self.downloadUserDataToTheApp(userUID: registeringUser.uid) {
                completion(.success("ok"))
            }
        }
        operationQueue.addOperation(addSecondDataPartOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
        operationQueue.addOperation(setupUserOperation)
        
    }
    //MARK: CHECK IF USER ALREADY EXISTS
    private func checkUserExistingInDatabase(userUID: String) -> Bool {
        guard let databaseSnapshot = self.lastDatabaseSnapshot else {
            return false
        }
        let allUsersDataDictionary = databaseSnapshot.value as? NSDictionary
        let userData = allUsersDataDictionary?.object(forKey: userUID) as? NSDictionary
        if userData == nil {
            return false
        } else {
            return true
        }
    }
    //MARK: -Setting up user data from database to the app
    public func downloadUserDataToTheApp(userUID: String, completion: @escaping () -> ()) {
        let setupUserOperation = BlockOperation {
            self.updateDatabaseSnapshot()
        }
        setupUserOperation.completionBlock = {
            guard let userDatabaseSnapshot = self.lastDatabaseSnapshot else {
                print("userDatabaseSnapshot == nil")
                return}
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
    func updateUserDataInTheApp(completion: @escaping () -> ()) {
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
