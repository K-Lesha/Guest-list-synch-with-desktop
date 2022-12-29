//
//  EventsListPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

//MARK: Protocol
protocol EventsListPresenterProtocol: AnyObject {
    //Propertis
    var eventsList: [EventEntity] {get set}
    init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol)
    // METHODS
    func setDataToTheView()
    func showProfile()
    func showEventGuestlist(eventEntity: EventEntity)
    func addNewEvent()
}

//MARK: Presenter
class EventsListPresenter: EventsListPresenterProtocol {
    //MARK: VIPER protocol
    private weak var view: EventsListViewControllerProtocol!
    private var router: RouterProtocol!
    private var interactor: EventsListInteractorProtocol!
    private var userUID: String!
    required init(view: EventsListViewControllerProtocol, interactor: EventsListInteractorProtocol, router: RouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    //MARK: Properties
    internal var eventsList: [EventEntity] = [EventEntity]()
    
    //MARK: METHODS
    func setDataToTheView() {
        self.interactor.readAllTheEvents { result in
            switch result {
            case .success(let eventsArray):
                self.eventsList = eventsArray
                self.view.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                self.view.showError()
            }
        }
    }
    func showProfile() {
        router.showProfileModule()
    }
    func showEventGuestlist(eventEntity: EventEntity) {
        router.showGuestslistModule(eventEntity: eventEntity)
    }
    func addNewEvent() {
        router.showAddModifyEventModule(state: .createEvent, eventEntity: nil)
    }
}
