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
    var modifiedGuestData: GuestEntity? {get set}
    //Methods
    func addNewGuest(guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
    func modifyGuest(completion: @escaping (String) -> ())
    func deleteGuest(completion: @escaping (String) -> ())
    func popViewController()
    func downloadGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

enum AddModifyOneGuestPresenterState {
    case addGuest
    case modifyGuest
}

class AddModifyGuestPresenter: AddModifyGuestPresenterProtocol {

    
    //MARK: -VIPER protocol
    weak var view: AddModifyGuestViewProtocol!
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
    var modifiedGuestData: GuestEntity?
    var eventID: String
    
    //MARK: -METHODS
    func modifyGuest(completion: @escaping (String) -> ()) {
        if let modifiedGuestData {
            interactor.modifyGuest(eventID: self.eventID, newGuestData: modifiedGuestData, completion: completion)
        }
    }
    func deleteGuest(completion: @escaping (String) -> ()) {
        guard let guest, state == .modifyGuest else {
            return
        }
        interactor.deleteOneGuest(eventID: self.eventID, guest: guest, completion: completion)
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
