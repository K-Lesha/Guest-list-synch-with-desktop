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
    var email: String {get set}
    var password: String  {get set}
    var userName: String  {get set}
    var userSurname: String? {get set}
    var userAgency: String? {get set}
    var userType: UserTypes {get set}
    // METHODS
    func setBackgroundImage(width: CGFloat, height: CGFloat, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func tryToRegisterWithFirebase(completion: @escaping (Result<String, FireBaseError>) -> ())
    func tryToLoginWithFirebase(completion: @escaping (Result<String, FireBaseError>) -> ())
    func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ())
    func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ())
    func checkInternetConnection() -> Bool
    func restorePasswordWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ())
    func showEventsListModule()
}

//MARK: Presenter
class AuthPresenter: AuthPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var view: AuthViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: AuthInteractorProtocol!
    
    required init(view: AuthViewProtocol, interactor: AuthInteractorProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    //MARK: TEMP DATA
    internal var userName: String = ""
    internal var password: String = ""
    internal var email: String = ""
    internal var userSurname: String? = ""
    internal var userAgency: String? = ""
    internal var userType: UserTypes = .headOrganizer
    
    //MARK: METHODS
    internal func setBackgroundImage(width: CGFloat, height: CGFloat, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let urlString = "https://source.unsplash.com/random/\(Int(width))x\(Int(height))?sig=1"
        print("presenter, setBackgroundImage", Thread.current)
        self.interactor.downloadImage(urlString: urlString, completionBlock: completion)
    }
    internal func tryToRegisterWithFirebase(completion: @escaping (Result<String, FireBaseError>) -> ()) {
        self.interactor.tryToRegisterWithFirebase(userName: self.userName, email: self.email, password: self.password, completion: completion)
    }
    internal func tryToLoginWithFirebase(completion: @escaping (Result<String, FireBaseError>) -> ()) {
        self.interactor.tryToLogInWithFirebase(email: self.email, password: self.password, completion: completion)
    }
    internal func tryToLoginWithFacebook(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ()) {
        self.interactor.tryToLoginWithFacebook(viewController: viewController, completion: completion)
    }
    internal func checkInternetConnection() -> Bool {
        return self.interactor.checkInternetConnection()
    }
    internal func restorePasswordWithFirebase(completion: @escaping (Result<Bool, FireBaseError>) -> ()) {
        self.interactor.restorePasswordWithFirebase(email: self.email, completion: completion)
    }
    internal func tryToLoginWithGoogle(viewController: SignInViewProtocol, completion: @escaping (Result<String, FireBaseError>) -> ()) {
        interactor.tryToLoginWithGoogle(viewController: viewController, completion: completion)
    }
    internal func showEventsListModule() {
        router.showEventsListModule()
    }

}
