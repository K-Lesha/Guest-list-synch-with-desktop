//
//  AddModifyEventPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 16.11.2022.
//

import Foundation

protocol AddModifyEventPresenterProtocol {
    // VIPER protocol
    var view: AddModifyEventViewProtocol! {get set}
    var interactor: AddModifyEventInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: AddModifyEventViewProtocol,
         interactor: AddModifyEventInteractorProtocol,
         router: RouterProtocol,
         eventID: String?,
         state: AddModifyEventPresenterState)
    //Properties
    var eventID: String? {get set}
    var state: AddModifyEventPresenterState {get set}
    var newEventData: EventEntity? {get set}
    //Methods
    func addNewEvent(completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
    func modifyEvent(completion: @escaping (String) -> ())
    func deleteEvent(completion: @escaping (String) -> ())

}

enum AddModifyEventPresenterState {
    case createEvent
    case modifyEvent
}

class AddModifyEventPresenter: AddModifyEventPresenterProtocol {
    //MARK: -VIPER PROTOCOL
    var view: AddModifyEventViewProtocol!
    var interactor: AddModifyEventInteractorProtocol!
    var router: RouterProtocol!
    //MARK: -INIT
    required init(view: AddModifyEventViewProtocol, interactor: AddModifyEventInteractorProtocol, router: RouterProtocol, eventID: String?, state: AddModifyEventPresenterState) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.eventID = eventID
        self.state = state
    }
    //MARK: -PROPERTIES
    var eventID: String?
    var state: AddModifyEventPresenterState
    var newEventData: EventEntity?
    
    //MARK: METHODS
    func addNewEvent(completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        
    }
    
    func modifyEvent(completion: @escaping (String) -> ()) {
        
    }
    
    func deleteEvent(completion: @escaping (String) -> ()) {
        
    }
}
