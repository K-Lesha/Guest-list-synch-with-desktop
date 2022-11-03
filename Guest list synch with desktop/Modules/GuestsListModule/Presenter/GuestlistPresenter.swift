//
//  GuestlistPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import Foundation

//MARK: Protocol
protocol GuestlistPresenterProtocol: AnyObject {
    // VIPER protocol
    var guestlistView: GuestlistViewProtocol! {get set}
    var interactor: GuestlistInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, event: EventEntity)
    // Properties
    var event: EventEntity! {get set}
    var guestlist: [GuestEntity] {get set}
    // METHODS
    func setGuestsToTheTable()
    func popToTheEventsList()
    func showGuest(guest: GuestEntity)
    func addNewGuest(guest: GuestEntity)
}

//MARK: Presenter
class GuestlistPresenter: GuestlistPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var guestlistView: GuestlistViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: GuestlistInteractorProtocol!
    internal var userUID: String!
    required init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, event: EventEntity) {
        self.guestlistView = guestlistView
        self.interactor = interactor
        self.router = router
        self.event = event
    }
    //MARK: Properties
    var event: EventEntity!
    var guestlist: [GuestEntity] = [GuestEntity]() {
        didSet {
            self.guestlistView.reloadData()
        }
    }


    //MARK: -METHODS
    func setGuestsToTheTable() {
        interactor.readEventGuests(eventID: self.event.eventUniqueIdentifier) { result in
            switch result {
            case .success(let guestlist):
                self.guestlist = guestlist
            case .failure(let error):
                print(error.localizedDescription)
                self.guestlistView.showError()
            }
        }
    }
    func addNewGuest(guest: GuestEntity) {
        interactor.addNewGuest(eventID: self.event.eventUniqueIdentifier, guest: guest) { result in
            switch result {
            case .success(_):
                print("guest added to google sheets")
                self.setGuestsToTheTable()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    
    func popToTheEventsList() {
        self.router.popOneController()
    }
    func showGuest(guest: GuestEntity) {
//        router.showGuestModule(guest: guest)
    }
    
    
}
