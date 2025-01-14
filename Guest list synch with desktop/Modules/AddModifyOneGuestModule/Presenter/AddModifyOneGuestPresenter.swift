//
//  AddModifyOneGuestPresenter.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import Foundation

protocol AddModifyGuestPresenterProtocol {
    // Init
    init(view: AddModifyGuestViewProtocol,
         interactor: AddModifyGuestInteractorProtocol,
         router: RouterProtocol,
         state: AddModifyOneGuestPresenterState,
         guest: GuestEntity?,
         event: EventEntity)
    // Data
    var state: AddModifyOneGuestPresenterState! {get set}
    var event: EventEntity {get set}
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
    //MARK: -Properties
    weak private var view: AddModifyGuestViewProtocol!
    private var interactor: AddModifyGuestInteractorProtocol!
    private var router: RouterProtocol!
    
    //MARK: -INIT
    required init(view: AddModifyGuestViewProtocol,
                  interactor: AddModifyGuestInteractorProtocol,
                  router: RouterProtocol,
                  state: AddModifyOneGuestPresenterState,
                  guest: GuestEntity?,
                  event: EventEntity) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.state = state
        if state == .modifyGuest {
            self.guest = guest
        }
        self.event = event
    }
    //MARK: -Data
    var state: AddModifyOneGuestPresenterState!
    var guest: GuestEntity?
    var modifiedGuestData: GuestEntity?
    var event: EventEntity
    
    //MARK: -METHODS
    func modifyGuest(completion: @escaping (String) -> ()) {
        if let modifiedGuestData {
            interactor.modifyGuest(event: self.event, newGuestData: modifiedGuestData, completion: completion)
        }
    }
    func deleteGuest(completion: @escaping (String) -> ()) {
        guard let guest, state == .modifyGuest else {
            return
        }
        interactor.deleteOneGuest(event: self.event, guest: guest, completion: completion)
    }

    func addNewGuest(guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        if state == .addGuest {
            interactor.addNewGuest(event: self.event, guest: guest, completion: completion)
        }
    }
    func popViewController() {
        router.popOneController()
    }
    

    func downloadGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        interactor.downloadGuestImage(stringURL: stringURL, completion: completion)
    }
    
    
}
