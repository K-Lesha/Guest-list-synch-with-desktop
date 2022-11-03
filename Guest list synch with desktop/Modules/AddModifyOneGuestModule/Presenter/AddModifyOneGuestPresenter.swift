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
    //Methods
    func modifyGuest()
    func addNewGuest(guest: GuestEntity)
    func deleteGuest()
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
    var eventID: String
    
    //MARK: -METHODS
    func modifyGuest() {
        if state == .modifyGuest {
            
        }
    }
    
    
    func addNewGuest(guest: GuestEntity) {
        guard state == .addGuest else { return }
        interactor.addNewGuest(eventID: self.eventID, guest: guest) { result in
            switch result {
            case .success(_):
                self.router.popOneController()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteGuest() {
       
    }
    
    
}
