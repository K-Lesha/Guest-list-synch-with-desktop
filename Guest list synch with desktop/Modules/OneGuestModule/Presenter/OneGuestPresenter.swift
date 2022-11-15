//
//  OneGuestPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 14.11.2022.
//

import Foundation

protocol OneGuestPresenterProtocol {
    // VIPER protocol
    var view: OneGuestViewPortocol! {get set}
    var interactor: OneGuestInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    // Init
    init(view: OneGuestViewPortocol, interactor: OneGuestInteractorProtocol, router: RouterProtocol, guest: GuestEntity, eventID: String)
    // Properties
    var guest: GuestEntity! {get set}
    var eventID: String!  {get set}
    //Methods
    func oneGuestEntered()
    func canselAllTheCheckins()
    func giftOneGift()
    func ungiftAllTheGifts()
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

class OneGuestPresenter: OneGuestPresenterProtocol {
    //MARK: -VIPER PROTOCOL
    var view: OneGuestViewPortocol!
    var interactor: OneGuestInteractorProtocol!
    var router: RouterProtocol!
    //MARK: -INIT

    required init(view: OneGuestViewPortocol, interactor: OneGuestInteractorProtocol, router: RouterProtocol, guest: GuestEntity, eventID: String) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.guest = guest
        self.eventID = eventID
    }
    //MARK: -Properties
    var guest: GuestEntity!
    var eventID: String!
    
    //MARK: -METHODS
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        interactor.setGuestPhoto(stringURL: stringURL, completion: completion)
    }

    func oneGuestEntered() {
        
    }
    func canselAllTheCheckins() {
        
    }
    func giftOneGift() {
        
    }
    func ungiftAllTheGifts() {
        
    }
    func showGuestEditModule(guest: GuestEntity) {
        router.showAddModifyGuestModule(state: .modifyGuest, guest: guest, eventID: self.eventID)
    }

}
