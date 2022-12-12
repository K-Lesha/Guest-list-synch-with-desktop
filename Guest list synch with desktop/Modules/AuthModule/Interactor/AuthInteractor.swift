//
//  AuthInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

protocol AuthInteractorProtocol {
    //VIPER protocol
    var networkService: NetworkServiceProtocol! {get set}
    var firebaseService: FirebaseServiceProtocol! {get set}
    var database: FirebaseDatabaseProtocol! {get set}
    // Init
    init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, database: FirebaseDatabaseProtocol)
    //Network methods
    func checkInternetConnection() -> Bool
    func downloadImage(urlString: String, completionBlock: @escaping (Result<Data, NetworkError>) -> Void)
    // Firebase methods
    func signUpWithFirebase(registeringUser: RegisteringUser,
                                   completion: @escaping (Result<String, FirebaseError>) -> ())
    func signInWithFirebase(registeringUser: RegisteringUser,
                                completion: @escaping (Result<String, FirebaseError>) -> ())
    func signInWithFacebook(viewController: SignInViewProtocol,
                                completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func signInWithGoogle(viewController: SignInViewProtocol,
                              completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func restorePasswordWithFirebase(email: String,
                                     completion: @escaping (Result<Bool, FirebaseError>) -> ())
    func finishFacebookGoogleRegistrationProcess(registeringUser: RegisteringUser,
                                                 completion: @escaping (Result<String, FirebaseError>) -> ())
}

class AuthInteractor: AuthInteractorProtocol {
    //MARK: -VIPER protocol
    internal var networkService: NetworkServiceProtocol!
    internal var firebaseService: FirebaseServiceProtocol!
    var database: FirebaseDatabaseProtocol!
    private let spreadsheetService: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    //MARK: -INIT
    internal required init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, database: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseService = firebaseService
        self.database = database
    }
    //MARK: -PROPERTIES
    let operationQueue = OperationQueue()
    //MARK: -NETWORK METHODS
    // AuthViewController
    internal func checkInternetConnection() -> Bool {
        networkService.checkInternetConnection()
    }
    internal func downloadImage(urlString: String, completionBlock: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: urlString, completionBlock: completionBlock)
    }
    //MARK: -SIGN UP WITH FIREBASE
    internal func signUpWithFirebase(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        self.firebaseService.signUpWithFirebase(registeringUser: registeringUser) { result in
            self.registrationCompletionHandler(result, completion: completion)
        }
    }
    private func registrationCompletionHandler(_ result: Result<RegisteringUser, FirebaseError>, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        switch result {
        case .success(let user):
            self.database.saveNewFirebaseUserToTheDatabase(registeringUser: user) { result in
                self.savingToDatabaseCompletionHandler(result, completion: completion)
            }
        case .failure(_):
            completion(.failure(.databaseError))
        }
    }
    private func savingToDatabaseCompletionHandler(_ result: Result<RegisteringUser, FirebaseError>, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        switch result {
        case .success(let user):
            self.addDemoEventToUserDatabase(user, completion: completion)
        case .failure(_):
            completion(.failure(.databaseError))
        }
    }
    private func addDemoEventToUserDatabase(_ user: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        let demoEvent = EventEntity.createDemoOfflineEvent(userUID: "demo event", userName: user.name)
        self.database.addOfflineEventToUserDatabase(event: demoEvent) { result in
            switch result {
            case .success(_):
                //3. set user data to database
                self.updateUserDataInTheApp(completion: completion)
            case .failure(_):
                completion(.failure(.databaseError))
            }
        }
    }
    private func updateUserDataInTheApp(completion: @escaping (Result<String, FirebaseError>) -> ()) {
        self.database.updateUserDataInTheApp {
            completion(.success("ok"))
        }
    }
    //MARK: -SIGN IN WITH FIREBASE
    internal func signInWithFirebase(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebaseService.signInWithFirebase(registeringUser: registeringUser) { result in
            self.singInWithFirebaseCompletion(result, completion: completion)
        }
    }
    private func singInWithFirebaseCompletion(_ result: Result<RegisteringUser, FirebaseError>, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        switch result {
        case .success(let user):
            self.downloadUserDataToTheApp(user, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    private func downloadUserDataToTheApp(_ user: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        database.downloadUserDataToTheApp(userUID: user.uid) {
            completion(.success("signInWithFirebase completed"))
        }
    }
    //MARK: -SIGN UP WITH FACEBOOK / GOOGLE
    internal func finishFacebookGoogleRegistrationProcess(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        let createNewUserInDatabaseBlock = BlockOperation {
            //1. create user data in database
            self.firebaseService.finishRegistrationWithFacebookOrGoogle(registeringUser: registeringUser) { _ in
                // 2. create demo offline event
                let demoEvent = EventEntity.createDemoOfflineEvent(userUID: registeringUser.uid, userName: registeringUser.name)
                // 3. set offline demo event to user database
                self.database.addOfflineEventToUserDatabase(event: demoEvent) { result in
                    switch result {
                    case .success(_):
                        //3. set user data to database
                            AuthenticationSemaphore.shared.signal()
                    case .failure(_):
                        completion(.failure(.databaseError))
                    }
                }
            }
        }
        let updateUserDataFromDatabaseToTheApp = BlockOperation {
            //4. update user data from database to app
            AuthenticationSemaphore.shared.wait()
            self.database.updateUserDataInTheApp {
                //5. send completion to UI
                completion(.success("ok"))
            }
        }
        operationQueue.addOperations([createNewUserInDatabaseBlock, updateUserDataFromDatabaseToTheApp], waitUntilFinished: false)
    }
    //MARK: -SIGN IN WITH FACEBOOK & GOOGLE
    internal func signInWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        firebaseService.signInWithFacebook(viewController: viewController, completion: completion)
    }
    internal func signInWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        firebaseService.signInWithGoogle(viewController: viewController, completion: completion)
    }
    //MARK: -FIREBASE RESTORE PASSWORD
    internal func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebaseService.resetFirebasePassword(email: email, completion: completion)
    }
}
