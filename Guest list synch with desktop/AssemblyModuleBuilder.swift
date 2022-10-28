//
//  AssemblyModuleBuilder.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit

protocol AssemblyBuilderProtocol {
    //Builder properties
    var networkService: NetworkServiceProtocol! {get set}
    var firebaseService: FirebaseServiceProtocol! {get set}
    init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol)
    //METHODS
    func createAuthModule(router: RouterProtocol) -> UIViewController
    func createEventsListViewController(router: RouterProtocol) -> UIViewController
}

class AssemblyModuleBuilder: AssemblyBuilderProtocol {
    //MARK: Builder properties
    internal var networkService: NetworkServiceProtocol!
    internal var firebaseService: FirebaseServiceProtocol!
    required init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol) {
        self.networkService = networkService
        self.firebaseService = firebaseService
    }
    
    //MARK: METHODS
    internal func createAuthModule(router: RouterProtocol) -> UIViewController {
        let view = AuthViewController()
        let interactor = AuthInteractor(networkService: self.networkService, firebaseService: self.firebaseService)
        let presenter = AuthPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
    internal func createEventsListViewController(router: RouterProtocol) -> UIViewController {
        let view = EventsListViewController()
        let interactor = EventsListInteractor(networkService: self.networkService)
        let presenter = EventsListPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
