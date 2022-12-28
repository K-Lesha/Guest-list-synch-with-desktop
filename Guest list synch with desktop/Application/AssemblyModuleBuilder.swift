//
//  AssemblyModuleBuilder.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit

protocol AssemblyBuilderProtocol {
    // Properties
    var networkService: NetworkServiceProtocol! {get set}
    var firebaseService: FirebaseServiceProtocol! {get set}
    var firebaseDatabase: FirebaseDatabaseProtocol! {get set}
    // INIT
    init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol)
    // METHODS
    func createAuthModule(router: RouterProtocol) -> UIViewController
    func createEventsListModule(router: RouterProtocol) -> UIViewController
    func createAddModifyEventModule(router: RouterProtocol,
                                    state: AddModifyEventPresenterState,
                                    eventEntity: EventEntity?) -> UIViewController
    func createGuestslistModule(router: RouterProtocol,
                                eventEntity: EventEntity) -> UIViewController
    func createOneGuestModule(router: RouterProtocol,
                              guest: GuestEntity,
                              event: EventEntity) -> UIViewController
    func createAddModifyOneGuestModule(router: RouterProtocol,
                                       state: AddModifyOneGuestPresenterState,
                                       guest: GuestEntity?,
                                       event: EventEntity) -> UIViewController
    func createProfileModule(router: RouterProtocol) -> UIViewController
}

class AssemblyModuleBuilder: AssemblyBuilderProtocol {
    //MARK: -Properties
    internal var networkService: NetworkServiceProtocol!
    internal var firebaseService: FirebaseServiceProtocol!
    internal var firebaseDatabase: FirebaseDatabaseProtocol!
    //MARK: -INIT
    required init(networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseService = firebaseService
        self.firebaseDatabase = firebaseDatabase
    }
    
    //MARK: -METHODS
    internal func createAuthModule(router: RouterProtocol) -> UIViewController {
        // just in case clean all the coockies
        self.firebaseService.signOut() {_ in
            
        }
        //init AuthModule
        let view = AuthViewController()
        let interactor = AuthInteractor(networkService: self.networkService, firebaseService: self.firebaseService, database: self.firebaseDatabase)
        let presenter = AuthPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
    internal func createEventsListModule(router: RouterProtocol) -> UIViewController {
        let view = EventsListViewController()
        let interactor = EventsListInteractor(firebaseDatabase: self.firebaseDatabase)
        let presenter = EventsListPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
    func createAddModifyEventModule(router: RouterProtocol,
                                    state: AddModifyEventPresenterState,
                                    eventEntity: EventEntity?) -> UIViewController {
        let view = AddModifyEventViewController(nibName: "AddModifyEventViewController", bundle: nil)
        let interactor = AddModifyEventInteractor(networkService: self.networkService, firebaseDatabase: self.firebaseDatabase)
        let presenter = AddModifyEventPresenter(view: view, interactor: interactor, router: router, eventEntity: eventEntity, state: state)
        view.presenter = presenter
        return view
    }
    internal func createGuestslistModule(router: RouterProtocol,
                                         eventEntity: EventEntity) -> UIViewController {
        let guestListView = GuestlistViewController()
        let interactor = GuestListInteractor(firebaseService: self.firebaseService, database: self.firebaseDatabase)
        let presenter = GuestlistPresenter(guestlistView: guestListView, interactor: interactor, router: router, eventEntity: eventEntity)
        guestListView.presenter = presenter
        return guestListView
    }
    func createOneGuestModule(router: RouterProtocol,
                              guest: GuestEntity,
                              event: EventEntity) -> UIViewController {
        let view = OneGuestViewController(nibName: "OneGuestViewController", bundle: nil)
        let interactor = OneGuestInteractor(networkService: self.networkService, database: self.firebaseDatabase)
        let presenter = OneGuestPresenter(view: view, interactor: interactor, router: router, guest: guest, event: event)
        view.presenter = presenter
        return view
    }
    func createAddModifyOneGuestModule(router: RouterProtocol,
                                       state: AddModifyOneGuestPresenterState,
                                       guest: GuestEntity?,
                                       event: EventEntity) -> UIViewController {
        let view = AddModifyGuestViewController(nibName: "AddModifyGuestViewController", bundle: nil)
        let interactor = AddModifyGuestInteractor(networkService: self.networkService, database: self.firebaseDatabase)
        let presenter = AddModifyGuestPresenter(view: view, interactor: interactor, router: router, state: state, guest: guest, event: event)
        view.presenter = presenter
        return view
    }
    internal func createProfileModule(router: RouterProtocol) -> UIViewController {
        let view = ProfileViewController()
        let interactor = ProfileInteractor(firebaseService: self.firebaseService, firebaseDatabase: self.firebaseDatabase)
        let presenter = ProfilePresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }
}
