//
//  Router.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit


protocol RouterProtocol: AnyObject {
    //Router properties
    var navigationController: UINavigationController! { get set }
    var assemblyBuilder: AssemblyBuilderProtocol! { get set }
    init (navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol)
    //METHODS
    func showAuthModule()
    func showEventsListModule()
    func showProfileModule()
    func showGuestslistModule(event: EventEntity)
    func popOneController()
}

class Router: RouterProtocol {
    //MARK: -Router properties
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
    public func showProfileModule() {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createProfileModule(router: self) else { return }
            navigationController.pushViewController(eventsListViewController, animated: true)
        }
    }
    public func showGuestslistModule(event: EventEntity) {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createGuestslistModule(router: self, event: event) else { return }
            navigationController.pushViewController(eventsListViewController, animated: true)
        }
    }
    public func popOneController() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
