//
//  EventsListPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

//MARK: Protocol
protocol EventsListPresenterProtocol: AnyObject {
    // VIPER protocol
    var view: EventsListViewControllerProtocol! {get set}
    var interactor: EventsListInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol, userUID: String)
    //TEMP DATA
    
    // METHODS
    
    
}

//MARK: Presenter
class EventsListPresenter: EventsListPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var view: EventsListViewControllerProtocol!
    internal weak var router: RouterProtocol!
    internal var interactor: EventsListInteractorProtocol!
    internal var userUID: String!
    required init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol, userUID: String) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.userUID = userUID
    }
    //MARK: TEMP DATA

    
    
    //MARK: METHODS
    
    
    
}
