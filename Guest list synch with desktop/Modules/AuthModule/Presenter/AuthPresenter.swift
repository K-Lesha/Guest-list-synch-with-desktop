//
//  AuthPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

//MARK: Protocol
protocol AuthPresenterProtocol: AnyObject {
    // VIPER protocol
    var view: AuthViewProtocol! {get set}
    var interactor: AuthInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: AuthViewProtocol, interactor: AuthInteractorProtocol, router: RouterProtocol)
    //TEMP DATA
    var registeringUser: RegisteringUser {get set}
//    var email: String {get set}
//    var password: String  {get set}
//    var userName: String  {get set}
//    var userSurname: String? {get set}
//    var userAgency: String? {get set}
//    var userType: UserTypes {get set}
//    var userUID: String {get set}
    // METHODS
    func setBackgroundImage(width: CGFloat, height: CGFloat, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func tryToRegisterWithFirebase(completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLoginWithFirebase(completion: @escaping (Result<String, FirebaseError>) -> ())
    func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ())
    func checkInternetConnection() -> Bool
    func restorePasswordWithFirebase(completion: @escaping (Result<Bool, FirebaseError>) -> ())
    func showEventsListModule()
    func finishFacebookGoogleRegistrationProcess(completion: @escaping (Result<String, FirebaseError>) -> ())
}

//MARK: Presenter
class AuthPresenter: AuthPresenterProtocol {
    //MARK: -VIPER protocol
    internal weak var view: AuthViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: AuthInteractorProtocol!
    
    required init(view: AuthViewProtocol, interactor: AuthInteractorProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    //MARK: -TEMP DATA
    internal var registeringUser = RegisteringUser.createEmptyRegisteringUser()
    
    //MARK: -METHODS
    // AuthViewController
    internal func checkInternetConnection() -> Bool {
        return self.interactor.checkInternetConnection()
    }
    internal func setBackgroundImage(width: CGFloat, height: CGFloat, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let urlString = "https://source.unsplash.com/random/\(Int(width))x\(Int(height))?sig=1"
        print("presenter, setBackgroundImage", Thread.current)
        self.interactor.downloadImage(urlString: urlString, completionBlock: completion)
    }
    // PasswordModalView
    internal func tryToLoginWithFirebase(completion: @escaping (Result<String, FirebaseError>) -> ()) {
        self.interactor.tryToLogInWithFirebase(registeringUser: self.registeringUser, completion: completion)
    }
    internal func restorePasswordWithFirebase(completion: @escaping (Result<Bool, FirebaseError>) -> ()) {
        self.interactor.restorePasswordWithFirebase(email: self.registeringUser.email, completion: completion)
    }
    // SignInModalView
    internal func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        self.interactor.tryToLoginWithFacebook(viewController: viewController, completion: completion)
    }
    internal func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<RegisteringUser, FirebaseError>) -> ()) {
        interactor.tryToLoginWithGoogle(viewController: viewController, completion: completion)
    }
    // FirebaseRegistrationModalView
    internal func tryToRegisterWithFirebase(completion: @escaping (Result<String, FirebaseError>) -> ()) {
        self.interactor.tryToRegisterWithFirebase(registeringUser: self.registeringUser, completion: completion)
    }
    // FinishFbGModalView
    internal func finishFacebookGoogleRegistrationProcess(completion: @escaping (Result<String, FirebaseError>) -> ()) {
        interactor.finishFacebookGoogleRegistrationProcess(registeringUser: self.registeringUser, completion: completion)
    }
    // FinishFbGModalView & FirebaseRegistrationModalView
    internal func showEventsListModule() {
        router.showEventsListModule()
    }

}
