//
//  FirebaseService.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST


protocol FirebaseServiceProtocol: AnyObject {
    //METHODS
    //Firebase methods
    func tryToRegisterWithFirebase(userName: String, email: String, password: String, completion: @escaping (Result<String, FireBaseError>) -> ())
    func tryToLogInWithFirebase(email: String, password: String, completion: @escaping (Result<String, FireBaseError>) -> ())
    func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FireBaseError>) -> ())
    func logOutWithFirebase()
    func reauthenticateAndDeleteUserWithFirebase(password: String, completion: @escaping (Result<Bool, FireBaseError>) -> ())
    func tryToDeleteAccountWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ())
    //Facebook methods
    func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ())
    func checkUserLoginnedWithFacebook() -> Bool
    //Google methods
    func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ())
    func checkUserLoginnedWithGoogle() -> Bool
    //Firebase database methods
    func findUsernameWithFirebaseDatabase(completion: @escaping (String) -> ())
}
//MARK: Firebase errors
enum FireBaseError: String, Error {
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
}
//MARK: Firebase Service
class FirebaseService: FirebaseServiceProtocol {
    //MARK: Firebase properties
    private let database = Database.database(url: "https://guest-list-295cc-default-rtdb.europe-west1.firebasedatabase.app/").reference().child("users")
    private let firebase = Auth.auth()
    
    //MARK: METHODS
    //MARK: - FIREBASE
    public func tryToRegisterWithFirebase(userName: String, email: String, password: String, completion: @escaping (Result<String, FireBaseError>) -> ()) {
        firebase.createUser(withEmail: email, password: password) { result, error in
            print("FirebaseService: tryToSignIn", Thread.current)
            if error != nil {
                completion(.failure(.registrationError))
                return
            }
            
            if let result {
                print(result.user.uid)
                self.database.child(result.user.uid).updateChildValues(["userName": userName, "email": email, "active": "yes", "signInProvider": "firebase"])
                completion(.success(result.user.uid))
            }
        }
        // in succesfull case SceneDelegate listener will change the state of app
    }
    public func tryToLogInWithFirebase(email: String, password: String, completion: @escaping (Result<String, FireBaseError>) -> ()) {
        firebase.signIn(withEmail: email, password: password) {result, error in
            guard error == nil else {
                completion(.failure(.loginError))
                return
            }
            // in succesfull case SceneDelegate listener will change the state of app
        }
    }
    public func logOutWithFirebase() {
        do {
            try firebase.signOut()
            //facebook log out
            let login = LoginManager()
            login.logOut()
            let cookies = HTTPCookieStorage.shared
            let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
                for cookie in facebookCookies! {
                    cookies.deleteCookie(cookie )
                }
            //google log out
            GIDSignIn.sharedInstance.signOut()
        } catch {
            print("can't log out")
        }
    }
    public func reauthenticateAndDeleteUserWithFirebase(password: String, completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
        guard let email = firebase.currentUser?.email else {
            print("email, is wrong")
            return completion(.failure(.wrongEmail))
        }
        
        //password confirmation with firebase
        let user = firebase.currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential) { result, error in
            if error != nil {
                print("Firebase service: logging in with email: \(email) and password: \(password) is failed")
                completion (.failure(.loginError))
            }
            if result != nil {
                //deleting
                self.tryToDeleteAccountWithFirebase() { deletionResult in
                    switch deletionResult {
                    case .success(_):
                        break
                        // in succesfull case SceneDelegate listener will change the state of app
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    public func tryToDeleteAccountWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
        guard let user = firebase.currentUser else {
            completion(.failure(.noSuchUserFindet))
            return
        }
        user.delete { error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.deletingError))
            } else {
                completion(.success(true))
                self.database.child(user.uid).updateChildValues(["active": "no"])
            }
        }
    }
    public func restorePasswordWithFirebase(email: String, completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
        firebase.sendPasswordReset(withEmail: email) { error in
            if error != nil {
                completion(.failure(.restoringPasswordError))
            } else {
                completion(.success(true))
            }
        }
    }
    
    //MARK: - FACEBOOK
    public func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ()) {
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
                    completion(.success("success"))
                    // in succesfull case SceneDelegate listener will change the app state
                    //in sucsessfull case save new user or update facebook user data to database
                    self.database.child(result?.user.uid ?? "facebookWrongID").updateChildValues(["userName": self.firebase.currentUser?.displayName ?? "facebookWrongName", "email": self.firebase.currentUser?.email ?? "facebookWrongMail", "active": "yes", "signInProvider": "facebook"])
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
    private let service = GTLRSheetsService()
    internal func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ()) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        print(FirebaseApp.app()?.options.clientID)
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController as! UIViewController) { user, error in
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
            //firebase sign in or log in with google credential
            self.firebase.signIn(with: credential) { result, error in
                if error != nil {
                    completion(.failure(.googleWithFirebaseLoginError))
                }

                //requestScopes for work with the spreadshits
                // in succesfull case SceneDelegate listener will change the app state
                //in sucsessfull case save new user or update facebook user data to database
                self.database.child(result?.user.uid ?? "googleWrongID").updateChildValues(["userName": self.firebase.currentUser?.displayName ?? "googleWrongName", "email": self.firebase.currentUser?.email ?? "googleWrongMail", "active": "yes", "signInProvider": "google"])
                return
            }
            self.requestScopes(viewController: viewController, googleUser: user!) { success in
                if success == true {
                    print("request scopes = success")
                    completion(.success("success"))
                } else {
                    print("request scopes = false")
                    completion(.failure(.googleWithFirebaseLoginError))
                }
            }
        }
    }
    public func requestScopes(viewController: SignInViewProtocol, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
        let grantedScopes = googleUser.grantedScopes
        if grantedScopes == nil || !grantedScopes!.contains(GoogleSpreadsheetsService.grantedScopes) {
            let additionalScopes = GoogleSpreadsheetsService.additionalScopes

            GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: viewController as! UIViewController) { user, scopeError in
                if scopeError == nil {
                    user?.authentication.do { authentication, err in
                        if err == nil {
                            guard let authentication = authentication else { return }
                            // Get the access token to attach it to a REST or gRPC request.
                           // let accessToken = authentication.accessToken
                            let authorizer = authentication.fetcherAuthorizer()
                            self.service.authorizer = authorizer
                            completionHandler(true)
                        } else {
                            print("Error with auth: \(String(describing: err?.localizedDescription))")
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
    public func checkUserLoginnedWithGoogle() -> Bool {
        return false
    }
    //MARK: - FIREBASE DATABASE METHODS
    public func findUsernameWithFirebaseDatabase(completion: @escaping (String) -> ()) {
        guard let user = firebase.currentUser else {
            return
        }
        database.queryOrderedByKey().observeSingleEvent(of: .value) { snapshot in
            let usersDictionary = snapshot.value as? NSDictionary
            let userData = usersDictionary?.object(forKey: user.uid) as? NSDictionary
            let userName = userData?.object(forKey: "userName") as? String
            guard let userName else { return }
            completion(userName)
        }
    }
}

