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
    var view: GuestlistViewProtocol! {get set}
    var interactor: GuestlistInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventID: String)
    // Properties
    var eventID: String! {get set}
    var guestlist: [GuestEntity] {get set}
    // METHODS
    func setGuestsToTheTable()
    func popToTheEventsList()
}

//MARK: Presenter
class GuestlistPresenter: GuestlistPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var view: GuestlistViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: GuestlistInteractorProtocol!
    internal var userUID: String!
    required init(view: GuestlistViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, eventID: String) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.eventID = eventID
        setGuestsToTheTable()
    }
    //MARK: Properties
    var eventID: String!
    var guestlist: [GuestEntity] = [GuestEntity]()


    //MARK: -METHODS
    func setGuestsToTheTable() {
        interactor.readEventGuests(eventID: self.eventID) { result in
            switch result {
            case .success(let guestlist):
                self.guestlist = guestlist
                self.view.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                self.view.showError()
            }
        }
    }
    func popToTheEventsList() {
        self.router.popOneController()
    }
    
}
