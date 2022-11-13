//
//  AddModifyOneGuestInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import Foundation

protocol AddModifyGuestInteractorProtocol {
    //VIPER protocol
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol {get set}
    var networkService: NetworkServiceProtocol! {get set}
    //init
    init(networkService: NetworkServiceProtocol)
    //Spreadsheet methods
    func readOneGuestInfo()
    func modifyOneGuestInfo()
    func deleteOneGuest()
    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
}

enum AddModifyOneGuestInteractorError: Error {
    case error
    case wrongEventID
    case spreadsheetsServiceError
    case noGuestsToShow
}

class AddModifyGuestInteractor: AddModifyGuestInteractorProtocol {
    
    //MARK: -VIPER protocol
    internal var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    internal var networkService: NetworkServiceProtocol!

    //MARK: INIT
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    
    //MARK: -Spreadsheets methods
    func readOneGuestInfo() {
        
    }
    
    func modifyOneGuestInfo() {
        
    }
    
    func deleteOneGuest() {
        
    }
    private func updateGuestImage() {
        
    }
    
    private func downloadGuestImage() {
        
    }

    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        self.spreadsheetsServise.appendData(spreadsheetID: eventID, range: .guestsDataForAdding, data: [" ",
                                                                                                        guest.guestName,
                                                                                                        guest.guestSurname ?? " ",
                                                                                                        guest.companyName ?? " ",
                                                                                                        guest.positionInCompany ?? " ",
                                                                                                        String(guest.guestGroup),
                                                                                                        String(guest.guestsAmount),
                                                                                                        String(guest.guestsEntered),
                                                                                                        String(guest.giftsGifted),
                                                                                                        guest.photoURL ?? " ",
                                                                                                        guest.phoneNumber ?? " ",
                                                                                                        guest.guestEmail ?? " ",
                                                                                                        guest.internalNotes ?? " ",
                                                                                                        guest.additionDate]) { string in
            completion(.success(true))
        }
    }
}
