//
//  ProfilePresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation

protocol ProfilePresenterProtocol {
    // Init
    init(view: ProfileViewControllerProtocol, interactor: ProfileInteractorProtocol, router: RouterProtocol)
    
    // METHODS
    func logOut()
}


class ProfilePresenter: ProfilePresenterProtocol {
    weak private var view: ProfileViewControllerProtocol!
    private var interactor: ProfileInteractorProtocol!
    private var router: RouterProtocol!
    
    //INIT
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
