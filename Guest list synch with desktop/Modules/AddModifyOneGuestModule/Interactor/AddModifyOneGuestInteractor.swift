//
//  AddModifyOneGuestInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import Foundation

protocol AddModifyGuestInteractorProtocol {
    //init
    init(networkService: NetworkServiceProtocol, database: FirebaseDatabaseProtocol)
    //Spreadsheet methods
    func modifyGuest(event: EventEntity, newGuestData: GuestEntity, completion: @escaping (String) -> ())
    func deleteOneGuest(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ())
    func addNewGuest(event: EventEntity, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
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
    private var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    private var networkService: NetworkServiceProtocol!
    private var database: FirebaseDatabaseProtocol!
    
    //MARK: INIT
    required init(networkService: NetworkServiceProtocol, database: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.database = database
    }
    
    
    //MARK: -Spreadsheets methods
    //MARK: Modify guest
    func modifyGuest(event: EventEntity, newGuestData: GuestEntity, completion: @escaping (String) -> ()) {
        if event.isOnline {
            self.modifyGuestInOnlineEvent(eventID: event.eventID, newGuestData: newGuestData, completion: completion)
        } else {
            self.modifyGuestInOfflineEvent(eventID: event.eventID, newGuestData: newGuestData, completion: completion)
        }
    }
    private func modifyGuestInOnlineEvent(eventID: String, newGuestData: GuestEntity, completion: @escaping (String) -> ()) {
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
    private func modifyGuestInOfflineEvent(eventID: String, newGuestData: GuestEntity, completion: @escaping (String) -> ()) {
        guard let offlineGuestID = newGuestData.offlineUID
        else {
            //completion false
            return
        }
        let guestData: NSDictionary = GuestEntity.createOneGuestDictFrom(newGuestData)
        self.database.updateOneGuestData(eventID: eventID, guestID: offlineGuestID, data: guestData, completion: completion)
    }
    //MARK: Add new guest
    func addNewGuest(event: EventEntity, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        if event.isOnline {
            self.addNewGuestToOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        } else {
            self.addNewGuestToOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func addNewGuestToOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
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
    private func addNewGuestToOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        guard let offlineGuestID = guest.offlineUID
        else {
            //completion false
            return
        }

        let guestData: NSDictionary = GuestEntity.createOneGuestDictFrom(guest)
        self.database.updateOneGuestData(eventID: eventID, guestID: offlineGuestID, data: guestData) {_ in
            completion(.success(true))
        }
    }
    //MARK: Delete guest
    func deleteOneGuest(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ()) {
        if event.isOnline {
            self.deleteGuestInOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        } else {
            self.deleteGuestInOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func deleteGuestInOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
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
    private func deleteGuestInOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let offlineGuestID = guest.offlineUID
        else {
            //completion false
            return
        }
        self.database.removeOneGuestFromDatabase(eventID: eventID, guestID: offlineGuestID, completion: completion)
    }
    //MARK: Other methods
    private func updateGuestImage() {
        
    }
    
    func downloadGuestImage(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: stringURL, completionBlock: completion)
    }

}
