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
    init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol)
    //Network methods
    func checkInternetConnection() -> Bool
    func downloadImage(urlString: String, completionBlock: @escaping (Result<Data, NetworkError>) -> Void)
    // Firebase methods
    func tryToRegisterWithFirebase(email: String, name: String, surname: String, agency: String, userTypeRawValue: Int, password: String, completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLogInWithFirebase(email: String, password: String, completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ())
    func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ())
    func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ())
    func finishFacebookGoogleRegistrationProcess(userUID: String, surname: String, agency: String, userTypeRawValue: Int, completion: @escaping (Result<String, FirebaseError>) -> ())
}

class AuthInteractor: AuthInteractorProtocol {
    //MARK: -VIPER protocol
    internal var networkService: NetworkServiceProtocol!
    internal var firebaseService: FirebaseServiceProtocol!
    private let spreadsheetService: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    internal required init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol) {
        self.networkService = networkService
        self.firebaseService = firebaseService
    }
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
    internal func tryToLogInWithFirebase(email: String, password: String, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebaseService.tryToLogInWithFirebase(email: email, password: password, completion: completion)
    }
    internal func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ()) {
        firebaseService.tryToLoginWithFacebook(viewController: viewController, completion: completion)
    }
    internal func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ()) {
        firebaseService.tryToSignInWithGoogle(viewController: viewController, completion: completion)
    }
    internal func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebaseService.restorePasswordWithFirebase(email: email, completion: completion)
    }
    // FirebaseRegistrationModalView
    internal func tryToRegisterWithFirebase(email: String, name: String, surname: String, agency: String, userTypeRawValue: Int, password: String, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        spreadsheetService.createDefaultSpreadsheet(named: "Demo guestlist", sheetType: .demoEvent) { eventID in
            self.firebaseService.tryToRegisterWithFirebase(email: email, name: name, surname: surname, agency: agency, userTypeRawValue: userTypeRawValue, demoEventID: eventID, password: password, completion: completion)
        }
    }
    // FinishFbGModalView
    internal func finishFacebookGoogleRegistrationProcess(userUID: String, surname: String, agency: String, userTypeRawValue: Int, completion: @escaping (Result<String, FirebaseError>) -> ()) {
        spreadsheetService.createDefaultSpreadsheet(named: "Demo guestlist", sheetType: .demoEvent) { eventID in
            self.firebaseService.finishRegistrationWithFacebookGoogle(userUID: userUID, surname: surname, agency: agency, userTypeRawValue: userTypeRawValue, demoEventID: eventID, completion: completion)
        }
    }
}
