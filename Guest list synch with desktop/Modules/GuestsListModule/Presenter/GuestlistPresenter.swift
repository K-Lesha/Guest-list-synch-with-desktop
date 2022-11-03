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
    var guestStaticticView: GuestStatisticViewProtocol! {get set}
    var interactor: GuestlistInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(guestlistView: GuestlistViewProtocol, guestStaticticView: GuestStatisticViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, event: EventEntity)
    // Properties
    var event: EventEntity! {get set}
    var guestlist: [GuestEntity] {get set}
    // METHODS
    func setGuestsToTheTable()
    func popToTheEventsList()
    func showGuest(guest: GuestEntity)
}

//MARK: Presenter
class GuestlistPresenter: GuestlistPresenterProtocol {
    //MARK: VIPER protocol
    internal weak var guestlistView: GuestlistViewProtocol!
    internal weak var guestStaticticView: GuestStatisticViewProtocol!
    internal var router: RouterProtocol!
    internal var interactor: GuestlistInteractorProtocol!
    internal var userUID: String!
    required init(guestlistView: GuestlistViewProtocol, guestStaticticView: GuestStatisticViewProtocol, interactor: GuestlistInteractorProtocol, router: RouterProtocol, event: EventEntity) {
        self.guestlistView = guestlistView
        self.guestStaticticView = guestStaticticView
        self.interactor = interactor
        self.router = router
        self.event = event
        setGuestsToTheTable()
    }
    //MARK: Properties
    var event: EventEntity!
    var guestlist: [GuestEntity] = [GuestEntity]()


    //MARK: -METHODS
    func setGuestsToTheTable() {
        interactor.readEventGuests(event: self.event) { result in
            switch result {
            case .success(let guestlist):
                self.guestlist = guestlist
                self.guestlistView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
                self.guestlistView.showError()
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
