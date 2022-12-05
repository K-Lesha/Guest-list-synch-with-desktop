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
    func modifyGuest(eventID: String, newGuestData: GuestEntity, completion: @escaping (String) -> ())
    func deleteOneGuest(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ())
    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
    //methods
    func downloadGuestImage(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) 
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
    
    func modifyGuest(eventID: String, newGuestData: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = newGuestData.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let newGuestDataForRow: [String] = [newGuestData.name,
                                            newGuestData.surname ?? "",
                                            newGuestData.company ?? "",
                                            newGuestData.position ?? "",
                                            newGuestData.group ?? "",
                                            String(newGuestData.guestsAmount),
                                            String(newGuestData.guestsEntered),
                                            String(newGuestData.giftsGifted),
                                            newGuestData.photoURL ?? "",
                                            newGuestData.phoneNumber ?? "",
                                            newGuestData.email ?? "",
                                            newGuestData.internalNotes ?? ""]
        spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "B\(row)", data: newGuestDataForRow, completionHandler: completion)
    }
    
    func deleteGuest(guest: GuestEntity) {
        
    }
    private func updateGuestImage() {
        
    }
    
    func downloadGuestImage(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        
    }
    
    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        self.spreadsheetsServise.appendData(spreadsheetID: eventID, range: .guestsDataForAdding, data: [" ",
                                                                                                        guest.name,
                                                                                                        guest.surname ?? " ",
                                                                                                        guest.company ?? " ",
                                                                                                        guest.position ?? " ",
                                                                                                        guest.group ?? " ",
                                                                                                        String(guest.guestsAmount),
                                                                                                        String(guest.guestsEntered),
                                                                                                        String(guest.giftsGifted),
                                                                                                        guest.photoURL ?? " ",
                                                                                                        guest.phoneNumber ?? " ",
                                                                                                        guest.email ?? " ",
                                                                                                        guest.internalNotes ?? " ",
                                                                                                        guest.additionDate]) { string in
            completion(.success(true))
        }
    }
    func deleteOneGuest(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let deletedGuestDataForRow: [String] = [guest.name,
                                                guest.surname ?? "",
                                                guest.company ?? "",
                                                guest.position ?? "",
                                                "удалённые",
                                                "0",
                                                "0",
                                                "0",
                                                guest.photoURL ?? "",
                                                guest.phoneNumber ?? "",
                                                guest.email ?? "",
                                                guest.internalNotes ?? ""]
        spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "B\(row)", data: deletedGuestDataForRow, completionHandler: completion)
    }
}
