//
//  ProfilePresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation

protocol ProfilePresenterProtocol {
    // VIPER protocol
    var view: ProfileViewControllerProtocol! {get set}
    var interactor: ProfileInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: ProfileViewControllerProtocol, interactor: ProfileInteractorProtocol, router: RouterProtocol)
    
    // METHODS
    func logOut()
}


class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol!
    var interactor: ProfileInteractorProtocol!
    var router: RouterProtocol!
    
    required init(view: ProfileViewControllerProtocol, interactor: ProfileInteractorProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router

    }
    
    func logOut() {
        interactor.logOut()
        router.showAuthModule()
    }
    
    
    
    
    
}
