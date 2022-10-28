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
    init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol)
    //TEMP DATA
    
    // METHODS
    func setDataToTheView(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void)
    
}

//MARK: Presenter
class EventsListPresenter: EventsListPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var view: EventsListViewControllerProtocol!
    internal weak var router: RouterProtocol!
    internal var interactor: EventsListInteractorProtocol!
    internal var userUID: String!
    required init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    //MARK: METHODS
    func setDataToTheView(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        interactor.readOneEventData(completionHandler: completionHandler)
    }
}
