//
//  AddModifyOneGuestPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import Foundation

protocol AddModifyGuestPresenterProtocol {
    // VIPER protocol
    var view: AddModifyGuestViewProtocol! {get set}
    var interactor: AddModifyGuestInteractorProtocol! {get set}
    var router: RouterProtocol! {get set}
    init(view: AddModifyGuestViewProtocol,
         interactor: AddModifyGuestInteractorProtocol,
         router: RouterProtocol,
         state: AddModifyOneGuestPresenterState,
         guest: GuestEntity?,
         eventID: String)
    // properties
    var state: AddModifyOneGuestPresenterState! {get set}
    var eventID: String {get set}
    var guest: GuestEntity? {get set}
    var newGuestData: GuestEntity? {get set}
    //Methods
    func addNewGuest(guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
    func modifyGuest()
    func deleteGuest()
    func popViewController()
    func downloadGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

enum AddModifyOneGuestPresenterState {
    case addGuest
    case modifyGuest
}

class AddModifyGuestPresenter: AddModifyGuestPresenterProtocol {

    
    //MARK: -VIPER protocol
    var view: AddModifyGuestViewProtocol!
    var interactor: AddModifyGuestInteractorProtocol!
    var router: RouterProtocol!
    
    //MARK: -INIT
    required init(view: AddModifyGuestViewProtocol,
                  interactor: AddModifyGuestInteractorProtocol,
                  router: RouterProtocol,
                  state: AddModifyOneGuestPresenterState,
                  guest: GuestEntity?,
                  eventID: String) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.state = state
        if state == .modifyGuest {
            self.guest = guest
        }
        self.eventID = eventID
    }
    //MARK: -PROPERTIES
    var state: AddModifyOneGuestPresenterState!
    var guest: GuestEntity?
    var newGuestData: GuestEntity?
    var eventID: String
    
    //MARK: -METHODS
    func modifyGuest() {
        if let oldGuestData = self.guest, let newGuestData = self.newGuestData {
            interactor.modifyGuest(guest: oldGuestData, newGuestData: newGuestData)
        }
    }
    func deleteGuest() {
        if state == .modifyGuest {
            interactor.deleteGuest(guest: self.guest!)
        }
    }
    
    func addNewGuest(guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        if state == .addGuest {
            interactor.addNewGuest(eventID: self.eventID, guest: guest, completion: completion)
        }
    }
    func popViewController() {
        router.popOneController()
    }
    

    func downloadGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        interactor.downloadGuestImage(stringURL: stringURL, completion: completion)
    }
    
    
}
