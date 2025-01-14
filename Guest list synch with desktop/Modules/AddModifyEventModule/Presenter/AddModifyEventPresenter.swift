//
//  AddModifyEventPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 16.11.2022.
//

import Foundation

protocol AddModifyEventPresenterProtocol {
    
    init(view: AddModifyEventViewProtocol,
         interactor: AddModifyEventInteractorProtocol,
         router: RouterProtocol,
         eventEntity: EventEntity?,
         state: AddModifyEventPresenterState)
    //Properties
    var eventEntity: EventEntity? {get set}
    var state: AddModifyEventPresenterState {get set}
    var newEventData: EventEntity? {get set}
    //Methods
    func addNewEvent(eventName: String,
                     eventVenue: String?,
                     eventDate: String,
                     eventTime: String?,
                     eventClient: String?,
                     isOnline: Bool,
                     completion: @escaping (Result<String, FirebaseDatabaseError>) -> ())
    func modifyEvent(completion: @escaping (String) -> ())
    func deleteEvent(completion: @escaping (String) -> ())
    //Navigation
    func showEventlistModule() 
    func popThisModule()
}

enum AddModifyEventPresenterState {
    case createEvent
    case modifyEvent
}

class AddModifyEventPresenter: AddModifyEventPresenterProtocol {
    //MARK: -VIPER PROTOCOL
    weak  private var view: AddModifyEventViewProtocol!
    private var interactor: AddModifyEventInteractorProtocol!
    private var router: RouterProtocol!
    //MARK: -INIT
    required init(view: AddModifyEventViewProtocol,
                  interactor: AddModifyEventInteractorProtocol,
                  router: RouterProtocol,
                  eventEntity: EventEntity?,
                  state: AddModifyEventPresenterState) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.eventEntity = eventEntity
        self.state = state
    }
    //MARK: -PROPERTIES
    internal var eventEntity: EventEntity?
    internal var state: AddModifyEventPresenterState
    internal var newEventData: EventEntity?
    
    //MARK: METHODS
    func addNewEvent(eventName: String,
                     eventVenue: String?,
                     eventDate: String,
                     eventTime: String?,
                     eventClient: String?,
                     isOnline: Bool,
                     completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        interactor.addNewEvent(eventName: eventName,
                               eventVenue: eventVenue,
                               eventDate: eventDate,
                               eventTime: eventTime,
                               eventClient: eventClient,
                               isOnline: isOnline,
                               completion: completion)
    }
    
    func modifyEvent(completion: @escaping (String) -> ()) {
        guard let newEventData,
        let eventEntity
        else {
            return
        }
        interactor.modifyEvent(eventEntity: eventEntity, newEventData: newEventData, completion: completion)
    }
    
    func deleteEvent(completion: @escaping (String) -> ()) {
        guard state == .modifyEvent,
            let eventEntity = self.eventEntity
        else {
            return
        }
        interactor.deleteEvent(eventEntity: eventEntity, completion: completion)
        
    }
    //MARK: Navigation
    func popThisModule() {
        router.popOneController()
    }
    func showEventlistModule() {
        self.router.showEventsListModule()
    }
}
