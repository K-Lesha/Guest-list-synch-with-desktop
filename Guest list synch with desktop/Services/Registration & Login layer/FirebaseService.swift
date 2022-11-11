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
    var database: FirebaseDatabaseProtocol! {get set}
    //init
    init(database: FirebaseDatabaseProtocol)
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
    //Facebook methods
    func tryToLoginWithFacebook(viewController: SignInViewProtocol,
                                completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ())
    //Google methods
    func tryToSignInWithGoogle(viewController: SignInViewProtocol,
                         completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ())
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
    static var logginnedUser: UserEntity? = nil
    private let firebase = Auth.auth()
    internal var database: FirebaseDatabaseProtocol!
    
    //MARK: INIT
    required init(database: FirebaseDatabaseProtocol) {
        self.database = database
    }
    
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
            guard error == nil, let result else {
                completion(.failure(.registrationError))
                return
            }
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
    public func tryToLogInWithFirebase(email: String,
                                       password: String,
                                       completion: @escaping (Result<String, FirebaseError>) -> ()) {
        firebase.signIn(withEmail: email, password: password) {result, error in
            guard error == nil, let user = result?.user else {
                completion(.failure(.loginError))
                return
            }
            self.database.setupUserFromDatabaseToTheApp(user: user) {
                completion(.success(user.uid))
            }
        }
    }
    public func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebase.sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                completion(.failure(.restoringPasswordError))
                return
            }
            completion(.success(true))
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
    public func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ()) {
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
                self.firebase.signIn(with: credential) { firebaseResult, error in
                    guard error == nil,
                    let firebaseResult,
                    let userName = firebaseResult.user.displayName,
                    let userEmail = firebaseResult.user.email,
                    let newUser = firebaseResult.additionalUserInfo?.isNewUser
                    else {
                        completion(.failure(.firebaseWithFacebookSignInError))
                        return
                    }
                    let userUID = firebaseResult.user.uid
                    //in sucsessfull case save new user or update facebook user data to database
                    self.database.firstStepSavingFacebookGoogleUserToTheDatabase(userUID: userUID,
                                                                                 name: userName,
                                                                                 email: userEmail,
                                                                                 signInProvider: "Facebook") { savingResult in
                        switch savingResult {
                        case .success(_):
                            completion(.success((userUID, userEmail, userName, newUser)))
                        case .failure(_):
                            completion(.failure(.databaseError))
                        }
                    }
                }
            }
        }
    }
        public func checkUserLoginnedWithFacebook() -> Bool {
            if let providerData = firebase.currentUser?.providerData {
                for userInfo in providerData {
                    switch userInfo.providerID {
                    case "facebook.com":
                        return true
                    default:
                        return false
                    }
                }
            }
            return false
        }
    //MARK: - GOOGLE
    internal func tryToSignInWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<(String, String, String, Bool), FirebaseError>) -> ()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config,
                                        presenting: viewController as! UIViewController,
                                        hint: nil,
                                        additionalScopes: GoogleSpreadsheetsService.additionalScopes) { user, error in
            guard error == nil,
                  let authentication = user?.authentication,
                  let idToken = authentication.idToken
            else {
                completion(.failure(.googleLoginError))
                return
            }
            // firebase sign in or log in with google credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            self.firebase.signIn(with: credential) { firebaseResult, error in
                guard error == nil,
                      let firebaseResult,
                      let userName = firebaseResult.user.displayName,
                      let userEmail = firebaseResult.user.email,
                      let newUser = firebaseResult.additionalUserInfo?.isNewUser
                else {
                    completion(.failure(.googleWithFirebaseLoginError))
                    return
                }
                let userUID = firebaseResult.user.uid
                // in sucsessfull case save new user or update google user data to database
                self.database.firstStepSavingFacebookGoogleUserToTheDatabase(userUID: userUID,
                                                                             name: userName,
                                                                             email: userEmail,
                                                                             signInProvider: "GoogleSignIn") { databaseResult in
                    switch databaseResult {
                    case .success(_):
                        completion(.success((userUID, userEmail, userName, newUser)))
                    case .failure(_):
                        completion(.failure(.databaseError))
                    }
                }
            }
        }
    }
//    public func requestScopes(viewController: UIViewController, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
//        let grantedScopes = googleUser.grantedScopes
//        if grantedScopes == nil || !grantedScopes!.contains(GoogleSpreadsheetsService.grantedScopes) {
//            let additionalScopes = GoogleSpreadsheetsService.additionalScopes
//            GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: viewController) { user, scopeError in
//                if scopeError == nil {
//                    user?.authentication.do { authentication, error in
//                        if error == nil {
//                            guard let authentication = authentication else { return }
//                            // Get the access token to attach it to a REST or gRPC request.
////                             let accessToken = authentication.accessToken
//                            completionHandler(true)
//                        } else {
//                            print("Error with auth: \(String(describing: error?.localizedDescription))")
//                            completionHandler(false)
//                        }
//                    }
//                } else {
//                    completionHandler(false)
//                    print("Error with adding scopes: \(String(describing: scopeError?.localizedDescription))")
//                }
//            }
//        } else {
//            print("Already contains the scopes!")
//            completionHandler(true)
//        }
//    }
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
                completion(.success("ok"))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.databaseError))
            }
        }
    }
}
