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
    func showLoggedInModule(userUID: String)
    func popToRoot()
}

class Router: RouterProtocol {
    //MARK: Router properties
    internal var navigationController: UINavigationController!
    internal var assemblyBuilder: AssemblyBuilderProtocol!
    
    required init (navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
    }
    //MARK: METHODS
    public func showAuthModule() {
        if let navigationController = navigationController {
            guard let authViewController = assemblyBuilder?.createMainModule(router: self) else { return }
            navigationController.viewControllers = [authViewController]
        }
    }
    public func showLoggedInModule(userUID: String) {
        if let navigationController = navigationController {
            guard let eventsListViewController = assemblyBuilder?.createSignInViewController(router: self, userUID: userUID) else { return }
            navigationController.viewControllers = [eventsListViewController]
        }
    }
    public func popToRoot() {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
