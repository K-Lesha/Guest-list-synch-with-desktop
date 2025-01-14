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
    //init
    init(database: FirebaseDatabaseProtocol)
    //METHODS
    //Registration methods
    func signUpWithFirebase(registeringUser: RegisteringUser,
                                    completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    // Sign In Methods
    func signInWithFirebase(registeringUser: RegisteringUser,
                                completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func signInWithFacebook(viewController: SignInViewProtocol,
                                completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func signInWithGoogle(viewController: SignInViewProtocol,
                         completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    //Sign Out Methods
    func signOut(completion: @escaping (Bool) -> ())
    //Firebase methods
    func resetFirebasePassword(email: String,
                                     completion: @escaping (Result<Bool, FirebaseError>) -> ())
    //Google Methods
    func checkIsUserSignedInWithGoogle() -> Bool
    func requestGoogleScopes(viewController: UIViewController, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void)
    //Other methods
    func finishRegistrationWithFacebookOrGoogle(registeringUser: RegisteringUser, completion: @escaping (Result<String, FirebaseError>) -> ())
}
//MARK: Firebase errors
enum FirebaseError: String, Error {
    //FirebseErrors
    case loginError
    case wrongEmail
    case wrongPassword
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
    private var database: FirebaseDatabaseProtocol!
    
    //MARK: INIT
    required init(database: FirebaseDatabaseProtocol) {
        self.database = database
    }
    
    //MARK: METHODS
    //MARK: - FIREBASE
    public func signUpWithFirebase(registeringUser: RegisteringUser,
                                          completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        //Check all the arguments
        guard let userPassword = registeringUser.password else {
            completion(.failure(.wrongPassword))
            return
        }
        // Firebase creating user
        firebase.createUser(withEmail: registeringUser.email, password: userPassword) { result, error in
            guard error == nil, let result else {
                completion(.failure(.registrationError))
                return
            }
            var registeringFirebaseUser = registeringUser
            registeringFirebaseUser.isNew = true
            registeringFirebaseUser.uid = result.user.uid
            registeringFirebaseUser.signInProvider = "Firebase"
            completion(.success(registeringFirebaseUser))
        }
    }
    public func signInWithFirebase(registeringUser: RegisteringUser,
                                       completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        firebase.signIn(withEmail: registeringUser.email, password: registeringUser.password ?? " ") {result, error in
            guard error == nil, let user = result?.user else {
                completion(.failure(.loginError))
                return
            }
            var registeringFirebaseUser = registeringUser
            registeringFirebaseUser.uid = user.uid
            completion(.success(registeringFirebaseUser))
        }
    }
    public func resetFirebasePassword(email: String, completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        firebase.sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                completion(.failure(.restoringPasswordError))
                return
            }
            completion(.success(true))
        }
    }
    public func signOut(completion: @escaping (Bool) -> ()) {
        let cookies = HTTPCookieStorage.shared
        do {
            //google log out
            GIDSignIn.sharedInstance.signOut()
            let googleCookies = cookies.cookies(for: URL(string: "https://google.com/")!)
            for cookie in googleCookies! {
                cookies.deleteCookie(cookie)
            }
            //facebook log out
            LoginManager().logOut()
            let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
            for cookie in facebookCookies! {
                cookies.deleteCookie(cookie)
            }
            //firebase logout
            try firebase.signOut()
            // installed in app user delete
            FirebaseService.logginnedUser = nil
            completion(true)
        } catch {
            completion(false)
        }
    }

    //MARK: - FACEBOOK
    public func signInWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
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
                let facebookCredential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
                // firebase sign in or log in with google credential
                self.completeFirstStepFacebookGoogleRegistrationWithFirebase(credential: facebookCredential, completion: completion)
            }
        }
    }
    //MARK: - GOOGLE
    internal func signInWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
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
            let googleCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            // firebase sign in or log in with google credential
            self.completeFirstStepFacebookGoogleRegistrationWithFirebase(credential: googleCredential, completion: completion)
        }
    }
    public func requestGoogleScopes(viewController: UIViewController, googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
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
    public func checkIsUserSignedInWithGoogle() -> Bool {
        if GIDSignIn.sharedInstance.currentUser != nil {
            return true
        } else {
            return false
        }
    }
    //MARK: -Common methods
    private func completeFirstStepFacebookGoogleRegistrationWithFirebase(credential: AuthCredential, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        //firebase sign in or log in with facebook credential
        self.firebase.signIn(with: credential) { firebaseResult, error in
            guard error == nil,
                  let firebaseResult,
                  let userName = firebaseResult.user.displayName,
                  let userEmail = firebaseResult.user.email,
                  let isNewUser = firebaseResult.additionalUserInfo?.isNewUser
            else {
                completion(.failure(.firebaseWithFacebookSignInError))
                return
            }
            let userUID = firebaseResult.user.uid
            let registeringUser = RegisteringUser(uid: userUID, name: userName, email: userEmail, signInProvider: credential.provider, isNew: isNewUser, surname: nil, userTypeRawValue: nil, agency: nil)
            //in sucsessfull case save new user or update facebook user data to database
            self.completeFirstStepSavingUserToDatabase(registeringUser: registeringUser, completion: completion)
        }
    }
    private func completeFirstStepSavingUserToDatabase(registeringUser: RegisteringUser, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        self.database.firstStepSavingFacebookGoogleUserToTheDatabase(registeringUser: registeringUser) { savingResult in
            switch savingResult {
            case .success(_):
                completion(.success(registeringUser))
            case .failure(_):
                completion(.failure(.databaseError))
            }
        }
    }
    public func finishRegistrationWithFacebookOrGoogle(registeringUser: RegisteringUser,
                                                     completion: @escaping (Result<String, FirebaseError>) -> ()) {
        database.finishStepSavingFacebookGoogleUserToTheDatabase(registeringUser: registeringUser) { result in
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
