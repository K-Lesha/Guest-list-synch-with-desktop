//
//  FirebaseService.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST


protocol FirebaseServiceProtocol: AnyObject {
    //METHODS
    //Firebase methods
    func tryToRegisterWithFirebase(email: String,
                                    name: String,
                                    surname: String,
                                    agency: String,
                                    userTypeRawValue: Int,
                                    demoEventID: String,
                                    password: String,
                                    completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLogInWithFirebase(email: String,
                                password: String,
                                completion: @escaping (Result<String, FirebaseError>) -> ())
    func restorePasswordWithFirebase(email: String,
                                     completion: @escaping (Result<Bool, FirebaseError>) -> ())
    func logOutWithFirebase()
//    func reauthenticateAndDeleteUserWithFirebase(password: String, completion: @escaping (Result<Bool, FireBaseError>) -> ())
//    func tryToDeleteAccountWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ())
    //Facebook methods
    func tryToLoginWithFacebook(viewController: SignInViewProtocol,
                                completion: @escaping (Result<(String, String, String), FirebaseError>) -> ())
    //Google methods
    func tryToSignInWithGoogle(viewController: SignInViewProtocol,
                         completion: @escaping (Result<(String, String, String), FirebaseError>) -> ())
    func tryToLoginWithGoogle(viewController: GuestlistViewProtocol,
                              completion: @escaping (Bool) -> ())
    func checkSignInWithGoogle(completion: @escaping (Bool) -> ())
    //Common methods
    func finishRegistrationWithFacebookGoogle(userUID: String, surname: String, agency: String, userTypeRawValue: Int, demoEventID: String, completion: @escaping (Result<String, FirebaseError>) -> ())
}
//MARK: Firebase errors
enum FirebaseError: String, Error {
    //FirebseErrors
    case loginError
    case wrongEmail
    case registrationError
    case deletingError
    case noSuchUserFindet
    case restoringPasswordError
    //Facebook errors
    case facebookLoginError
    case facebookLoginCanselled
    case firebaseWithFacebookSignInError
    //Google errors
    case googleLoginError
    case googleWithFirebaseLoginError
    //Database errors
    case databaseError
}
//MARK: Firebase Service
class FirebaseService: FirebaseServiceProtocol {
    //MARK: Firebase properties
    private let firebase = Auth.auth()
    private let database = FirebaseDatabase()
    static var logginnedUser: UserEntity? = nil
    
    //MARK: METHODS
    //MARK: - FIREBASE
    public func tryToRegisterWithFirebase(email: String,
                                          name: String,
                                          surname: String,
                                          agency: String,
                                          userTypeRawValue: Int,
                                          demoEventID: String,
                                          password: String,
                                          completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebase.createUser(withEmail: email, password: password) { result, error in
            print("FirebaseService: tryToSignIn", Thread.current)
            if error != nil {
                completion(.failure(.registrationError))
                return
            }
            if let result {
                print(result.user.uid)
                self.database.saveNewFirebaseUserToTheDatabase(userUID: result.user.uid,
                                                               email: email,
                                                               name: name,
                                                               surname: surname,
                                                               agency: agency,
                                                               userTypeRawValue: userTypeRawValue,
                                                               signInProvider: "Firebase",
                                                               demoEventID: demoEventID) { savingResult in
                    switch savingResult {
                    case .success(_):
                        completion(.success(result.user.uid))
                    case .failure(_):
                        completion(.failure(.databaseError))
                    }
                }
            }
        }
        // in succesfull case SceneDelegate listener will change the state of app
    }
    public func tryToLogInWithFirebase(email: String,
                                       password: String,
                                       completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebase.signIn(withEmail: email, password: password) {result, error in
            guard error == nil else {
                completion(.failure(.loginError))
                return
            }
            guard let user = result?.user else {
                completion(.failure(.loginError))
                return
            }
            completion(.success(user.uid))
            self.setupUserToTheApp(user: user)
        }
    }
    //    public func reauthenticateAndDeleteUserWithFirebase(password: String, completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
    //        guard let email = firebase.currentUser?.email else {
    //            print("email, is wrong")
    //            return completion(.failure(.wrongEmail))
    //        }
    //        //password confirmation with firebase
    //        let user = firebase.currentUser
    //        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    //        user?.reauthenticate(with: credential) { result, error in
    //            if error != nil {
    //                print("Firebase service: logging in with email: \(email) and password: \(password) is failed")
    //                completion (.failure(.loginError))
    //            }
    //            if result != nil {
    //                //deleting
    //                self.tryToDeleteAccountWithFirebase() { deletionResult in
    //                    switch deletionResult {
    //                    case .success(_):
    //                        break
    //                        // in succesfull case SceneDelegate listener will change the state of app
    //                    case .failure(let error):
    //                        completion(.failure(error))
    //                    }
    //                }
    //            }
    //        }
    //    }
    //    public func tryToDeleteAccountWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
    //        guard let user = firebase.currentUser else {
    //            completion(.failure(.noSuchUserFindet))
    //            return
    //        }
    //        user.delete { error in
    //            if let error = error {
    //                print(error.localizedDescription)
    //                completion(.failure(.deletingError))
    //            } else {
    //                completion(.success(true))
    //                self.database.updateValues(userUID: user.uid, key: "active", value: "false")
    //            }
    //        }
    //    }
    public func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebase.sendPasswordReset(withEmail: email) { error in
            if error != nil {
                completion(.failure(.restoringPasswordError))
            } else {
                completion(.success(true))
            }
        }
    }
    public func logOutWithFirebase() {
        do {
            //firebase logout
            try firebase.signOut()
            //facebook log out
            LoginManager().logOut()
            let cookies = HTTPCookieStorage.shared
            let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
            for cookie in facebookCookies! {
                cookies.deleteCookie(cookie)
            }
            //google log out
            GIDSignIn.sharedInstance.signOut()
            let googleCookies = cookies.cookies(for: URL(string: "https://google.com/")!)
            for cookie in googleCookies! {
                cookies.deleteCookie(cookie)
            }
        } catch {
            print("can't log out")
        }
    }
    //MARK: - FACEBOOK
    public func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String), FirebaseError>) -> ()) {
        //log in with facebook
        let login = LoginManager()
        login.logIn(permissions: ["email", "public_profile"], from: viewController as? UIViewController) { result, error in
            if result?.isCancelled ?? false {
                completion(.failure(.facebookLoginCanselled))
                return
            }
            guard error == nil else {
                completion(.failure(.facebookLoginError))
                return
            }
            // facebook graph request for registrate or log in with firebase
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET")).start() { graphRequestConnecting, result, error in
                guard error == nil else {
                    completion(.failure(.facebookLoginError))
                    return
                }
                //facebook credential
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
                //firebase sign in or log in with facebook credential
                self.firebase.signIn(with: credential) { result, error in
                    guard error == nil else {
                        completion(.failure(.firebaseWithFacebookSignInError))
                        return
                    }
                    guard let result else {
                        completion(.failure(.firebaseWithFacebookSignInError))
                        return
                    }
                    //in sucsessfull case save new user or update facebook user data to database
                    self.database.firstStepSavingFacebookGoogleUserToTheDatabase(userUID: result.user.uid,
                                                                                 name: self.firebase.currentUser?.displayName ?? "googleWrongName",
                                                                                 email: self.firebase.currentUser?.email ?? "googleWrongMail",
                                                                                 signInProvider: "GoogleSignIn") { result in
                        switch result {
                        case .success(_):
                            guard let currentUserUID = Auth.auth().currentUser?.uid,
                                  let email = Auth.auth().currentUser?.email,
                                  let userName = Auth.auth().currentUser?.displayName else {
                                completion(.failure(.databaseError))
                                return
                            }
                            completion(.success((currentUserUID, email, userName)))
                        case .failure(_):
                            completion(.failure(.databaseError))
                        }
                    }
                }
            }
        }
    }
    //    public func checkUserLoginnedWithFacebook() -> Bool {
    //        if let providerData = firebase.currentUser?.providerData {
    //            for userInfo in providerData {
    //                switch userInfo.providerID {
    //                case "facebook.com":
    //                    return true
    //                default:
    //                    return false
    //                }
    //            }
    //        }
    //        return false
    //    }
    //MARK: - GOOGLE
    internal func tryToSignInWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String), FirebaseError>) -> ()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config,
                                        presenting: viewController as! UIViewController,
                                        hint: nil,
                                        additionalScopes: ["https://www.googleapis.com/auth/spreadsheets",
                                                           "https://www.googleapis.com/auth/drive.file"]) { user, error in
            if error != nil {
                completion(.failure(.googleLoginError))
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                completion(.failure(.googleLoginError))
                return
            }
            //google credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
//            //firebase sign in or log in with google credential
            self.firebase.signIn(with: credential) { result, error in
                if error != nil {
                    completion(.failure(.googleWithFirebaseLoginError))
                }
                guard let result else {
                    completion(.failure(.firebaseWithFacebookSignInError))
                    return
                }
//              in sucsessfull case save new user or update google user data to database
                self.database.firstStepSavingFacebookGoogleUserToTheDatabase(userUID: result.user.uid,
                                                                             name: self.firebase.currentUser?.displayName ?? "googleWrongName",
                                                                             email: self.firebase.currentUser?.email ?? "googleWrongMail",
                                                                             signInProvider: "GoogleSignIn") { result in
                    switch result {
                    case .success(_):
                        guard let currentUserUID = Auth.auth().currentUser?.uid,
                              let email = Auth.auth().currentUser?.email,
                              let userName = Auth.auth().currentUser?.displayName else {
                            completion(.failure(.databaseError))
                            return
                        }
                        completion(.success((currentUserUID, email, userName)))
                    case .failure(_):
                        completion(.failure(.databaseError))
                    }
                }
            }
        }
    }
    internal func tryToLoginWithGoogle(viewController: GuestlistViewProtocol, completion: @escaping (Bool) -> ()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController as! UIViewController, hint: nil, additionalScopes: ["https://www.googleapis.com/auth/spreadsheets"]) { user, error in
            if error != nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
    public func requestScopes(viewController: UIViewController, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
        let grantedScopes = googleUser.grantedScopes
        if grantedScopes == nil || !grantedScopes!.contains(GoogleSpreadsheetsService.grantedScopes) {
            let additionalScopes = GoogleSpreadsheetsService.additionalScopes
            GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: viewController) { user, scopeError in
                if scopeError == nil {
                    user?.authentication.do { authentication, error in
                        if error == nil {
                            guard let authentication = authentication else { return }
                            // Get the access token to attach it to a REST or gRPC request.
//                             let accessToken = authentication.accessToken
                            completionHandler(true)
                        } else {
                            print("Error with auth: \(String(describing: error?.localizedDescription))")
                            completionHandler(false)
                        }
                    }
                } else {
                    completionHandler(false)
                    print("Error with adding scopes: \(String(describing: scopeError?.localizedDescription))")
                }
            }
        } else {
            print("Already contains the scopes!")
            completionHandler(true)
        }
    }
    public func checkSignInWithGoogle(completion: @escaping (Bool) -> ()) {
        if GIDSignIn.sharedInstance.currentUser != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
    //MARK: -Common methods
    public func finishRegistrationWithFacebookGoogle(userUID: String,
                                                     surname: String,
                                                     agency: String,
                                                     userTypeRawValue: Int,
                                                     demoEventID: String,
                                                     completion: @escaping (Result<String, FirebaseError>) -> ()) {
        database.finishStepSavingFacebookGoogleUserToTheDatabase(userUID: userUID,
                                                                 surname: surname,
                                                                 userTypeRawValue: userTypeRawValue,
                                                                 demoEventID: demoEventID,
                                                                 agency: agency) { result in
            switch result {
            case .success(let string):
                print(string)
                guard let currentUser = Auth.auth().currentUser else {
                    completion(.failure(.databaseError))
                    return
                    }
                self.setupUserToTheApp(user: currentUser)
                completion(.success("ok"))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.databaseError))
            }
        }
    }
    public func setupUserToTheApp(user: User) {
        self.database.setupUserToTheApp(user: user)
    }
}
