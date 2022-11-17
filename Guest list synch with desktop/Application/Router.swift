//
//  Router.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit


protocol RouterProtocol: AnyObject {
    // Properties
    var navigationController: UINavigationController! { get set }
    var assemblyBuilder: AssemblyBuilderProtocol! { get set }
    // INIT
    init (navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol)
    // METHODS
    func showAuthModule()
    func showEventsListModule()
    func showAddModifyEventModule(state: AddModifyEventPresenterState, eventEntity: EventEntity?)
    func showProfileModule()
    func showGuestslistModule(eventEntity: EventEntity)
    func showOneGuestModule(guest: GuestEntity,
                            eventID: String)
    func showAddModifyGuestModule(state: AddModifyOneGuestPresenterState,
                                  guest: GuestEntity?,
                                  eventID: String)
    func popOneController()
}

class Router: RouterProtocol {
    //MARK: -Properties
    internal var navigationController: UINavigationController!
    internal var assemblyBuilder: AssemblyBuilderProtocol!
    
    required init (navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
    }
    //MARK: -METHODS
    public func showAuthModule() {
        if let navigationController = navigationController {
            guard let authViewController = assemblyBuilder?.createAuthModule(router: self) else { return }
            navigationController.viewControllers = [authViewController]
        }
    }
    public func showEventsListModule() {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createEventsListModule(router: self) else { return }
            navigationController.viewControllers = [eventsListViewController]
        }
    }
    public func showAddModifyEventModule(state: AddModifyEventPresenterState, eventEntity: EventEntity?) {
        if let navigationController = navigationController {
            guard let addModifyEventViewController = assemblyBuilder?.createAddModifyEventModule(router: self, state: state, eventEntity: eventEntity) else { return }
            navigationController.pushViewController(addModifyEventViewController, animated: true)
        }
    }
    public func showProfileModule() {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createProfileModule(router: self) else { return }
            navigationController.pushViewController(eventsListViewController, animated: true)
        }
    }
    public func showGuestslistModule(eventEntity: EventEntity) {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createGuestslistModule(router: self, eventEntity: eventEntity) else { return }
            navigationController.pushViewController(eventsListViewController, animated: true)
        }
    }
    public func showOneGuestModule(guest: GuestEntity, eventID: String) {
        if let navigationController = navigationController {
            guard let addModifyViewController = assemblyBuilder?.createOneGuestModule(router: self, guest: guest, eventID: eventID) else { return }
            navigationController.pushViewController(addModifyViewController, animated: true)
        }
    }
    public func showAddModifyGuestModule(state: AddModifyOneGuestPresenterState, guest: GuestEntity?, eventID: String) {
        if let navigationController = navigationController {
            guard let addModifyGuestViewController = assemblyBuilder?.createAddModifyOneGuestModule(router: self, state: state, guest: guest, eventID: eventID) else { return }
            navigationController.pushViewController(addModifyGuestViewController, animated: true)
        }
    }
    public func popOneController() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
