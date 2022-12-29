//
//  GuestlistPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import Foundation

//MARK: Protocol
protocol GuestlistPresenterProtocol: AnyObject {
    init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventEntity: EventEntity)
    // Properties
    var eventEntity: EventEntity! {get set}
    var guestlist: [GuestEntity] {get set}
    var guestlistFiltred: [GuestEntity] {get set}
    // METHODS
    func setGuestsToTheTable()
    func updateEventEntity()
    //Navigation
    func showOneGuest(guest: GuestEntity)
    func addNewGuest()
    func popToTheEventsList()
    func showEventModifyModule()
}

//MARK: Presenter
class GuestlistPresenter: GuestlistPresenterProtocol {
    
    //MARK: Properties
    private weak var guestlistView: GuestlistViewProtocol!
    private var router: RouterProtocol!
    private var interactor: GuestlistInteractorProtocol!
    
    //MARK: -INIT
    required init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventEntity: EventEntity) {
        self.guestlistView = guestlistView
        self.interactor = interactor
        self.router = router
        self.eventEntity = eventEntity
    }
    //MARK: Data
    var eventEntity: EventEntity!
    var guestlist: [GuestEntity] = [GuestEntity]() {
        didSet {
            guestlistFiltred = guestlist.filter { !$0.empty && $0.guestsAmount > 0 }
        }
    }
    var guestlistFiltred: [GuestEntity] = [GuestEntity]() {
        didSet {
            DispatchQueue.main.async {
                self.guestlistView.reloadData()
            }
        }
    }
    
    
    //MARK: -METHODS
    func setGuestsToTheTable() {
        interactor.readEventGuests(event: eventEntity) { result in
            switch result {
            case .success(let guestlist):
                self.guestlist = guestlist
            case .failure(let error):
                DispatchQueue.main.async {
                    if error == .noGuestsToShow {
                        self.guestlistView.noGuestToShowAlert()
                    }
                    self.guestlistView.showReadGuestsError()
                }
            }
        }
    }
    func updateEventEntity() {
        interactor.updateEventEntity(eventEntity: self.eventEntity) { result in
            switch result {
            case .success(let newEventEntity):
                self.eventEntity = newEventEntity
            case .failure(_):
                print("error")
            }
        }
    }

    //MARK: -NAVIGATION
    func showEventModifyModule() {
        router.showAddModifyEventModule(state: .modifyEvent, eventEntity: self.eventEntity)
    }
    func popToTheEventsList() {
        self.router.popOneController()
    }
    func showOneGuest(guest: GuestEntity) {
        router.showOneGuestModule(guest: guest, event: self.eventEntity)
    }
    func addNewGuest() {
        router.showAddModifyGuestModule(state: .addGuest, guest: nil, event: eventEntity)
    }
}
