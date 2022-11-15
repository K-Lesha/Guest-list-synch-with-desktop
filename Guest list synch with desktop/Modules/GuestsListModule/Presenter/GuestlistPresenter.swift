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
    init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventID: String)
    // Properties
    var eventID: String! {get set}
    var guestlist: [GuestEntity] {get set}
    var guestlistFiltred: [GuestEntity] {get set}
    // METHODS
    func setGuestsToTheTable()
    func popToTheEventsList()
    func showOneGuest(guest: GuestEntity)
    func addNewGuest()
}

//MARK: Presenter
class GuestlistPresenter: GuestlistPresenterProtocol {

    
    
    //MARK: VIPER protocol
    internal weak var guestlistView: GuestlistViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: GuestlistInteractorProtocol!
    internal var userUID: String!
    
    //MARK: -INIT
    required init(guestlistView: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventID: String) {
        self.guestlistView = guestlistView
        self.interactor = interactor
        self.router = router
        self.eventID = eventID
    }
    //MARK: Properties
    var eventID: String!
    var guestlist: [GuestEntity] = [GuestEntity]() {
        didSet {
            guestlistFiltred = guestlist.filter { !$0.empty }
        }
    }
    var guestlistFiltred: [GuestEntity] = [GuestEntity]() {
        didSet {
            self.guestlistView.reloadData()
        }
    }


    //MARK: -METHODS
    func setGuestsToTheTable() {
        interactor.readEventGuests(eventID: eventID) { result in
            switch result {
            case .success(let guestlist):
                self.guestlist = guestlist
            case .failure(let error):
                print(error.localizedDescription)
                self.guestlistView.showReadGuestsError()
            }
        }
    }
    
    
    
    func popToTheEventsList() {
        self.router.popOneController()
    }
    func showOneGuest(guest: GuestEntity) {
        router.showOneGuestModule(guest: guest, eventID: self.eventID)
    }
    func addNewGuest() {
        router.showAddModifyGuestModule(state: .addGuest, guest: nil, eventID: eventID)
    }
}
