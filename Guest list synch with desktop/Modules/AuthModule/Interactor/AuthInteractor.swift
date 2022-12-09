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
    func tryToRegisterWithFirebase(registeringUser: RegisteringUser,
                                   completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLogInWithFirebase(registeringUser: RegisteringUser,
                                completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLoginWithFacebook(viewController: SignInViewProtocol,
                                completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func tryToLoginWithGoogle(viewController: SignInViewProtocol,
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
    //MARK: -Network methods
    // AuthViewController
    internal func checkInternetConnection() -> Bool {
        networkService.checkInternetConnection()
    }
    internal func downloadImage(urlString: String, completionBlock: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: urlString, completionBlock: completionBlock)
    }
    //MARK: -Firebase calls
    // PasswordModalView
    internal func tryToLogInWithFirebase(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebaseService.signInWithFirebase(registeringUser: registeringUser, completion: completion)
    }
    internal func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        firebaseService.loginWithFacebook(viewController: viewController, completion: completion)
    }
    internal func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        firebaseService.loginWithGoogle(viewController: viewController, completion: completion)
    }
    internal func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebaseService.resetPasswordWithFirebase(email: email, completion: completion)
    }
    // FirebaseRegistrationModalView
    internal func tryToRegisterWithFirebase(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        //1. create user data in firebathe auth service
        self.firebaseService.createUserProfileUsingFirebase(registeringUser: registeringUser) {_ in
            // 2. create demo offline event
            let demoEvent = EventEntity.createDemoOfflineEvent(userUID: "demo event", userName: registeringUser.name)
            // 3. set offline demo event to user database
            self.database.addOfflineEventToUserDatabase(event: demoEvent) { result in
                switch result {
                case .success(_):
                    //3. set user data to database
                    self.database.updateUserDataInTheApp {
                        completion(.success("ok"))
                    }
                case .failure(_):
                    completion(.failure(.databaseError))
                }
            }
        }
    }
    // FinishFbGModalView
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
    
    
    
}
