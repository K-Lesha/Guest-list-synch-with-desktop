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
    var firebaseDatabase: FirebaseDatabaseProtocol! {get set}
    init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol)
    //METHODS
    func createAuthModule(router: RouterProtocol) -> UIViewController
    func createEventsListModule(router: RouterProtocol) -> UIViewController
    func createGuestslistModule(router: RouterProtocol, event: EventEntity) -> UIViewController
    func createProfileModule(router: RouterProtocol) -> UIViewController
}

class AssemblyModuleBuilder: AssemblyBuilderProtocol {
    //MARK: -Builder properties
    internal var networkService: NetworkServiceProtocol!
    internal var firebaseService: FirebaseServiceProtocol!
    internal var firebaseDatabase: FirebaseDatabaseProtocol!
    required init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseService = firebaseService
        self.firebaseDatabase = firebaseDatabase
    }
    
    //MARK: -METHODS
    internal func createAuthModule(router: RouterProtocol) -> UIViewController {
        let view = AuthViewController()
        let interactor = AuthInteractor(networkService: self.networkService, firebaseService: self.firebaseService)
        let presenter = AuthPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
    internal func createEventsListModule(router: RouterProtocol) -> UIViewController {
        let view = EventsListViewController()
        let interactor = EventsListInteractor()
        let presenter = EventsListPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
    internal func createGuestslistModule(router: RouterProtocol, event: EventEntity) -> UIViewController {
        let guestListView = GuestlistViewController()
        let guestStatisticView = GuestsStaticticViewController()
        let interactor = GuestListInteractor()
        let presenter = GuestlistPresenter(guestlistView: guestListView, guestStaticticView: guestStatisticView, interactor: interactor, router: router, event: event)
        guestListView.presenter = presenter
        guestStatisticView.presenter = presenter
        let tabBarViewController = UITabBarController()
        tabBarViewController.setViewControllers([guestListView, guestStatisticView], animated: true)
        return tabBarViewController
    }
    internal func createProfileModule(router: RouterProtocol) -> UIViewController {
        let view = ProfileViewController()
        let interactor = ProfileInteractor(firebaseService: self.firebaseService, firebaseDatabase: self.firebaseDatabase)
        let presenter = ProfilePresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
