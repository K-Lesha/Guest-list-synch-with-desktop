//
//  OneGuestInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 14.11.2022.
//

import Foundation

protocol OneGuestInteractorProtocol {
    // VIPER PROTOCOL
    var networkService: NetworkServiceProtocol! {get set}
    var database: FirebaseDatabaseProtocol! {get set}
    // Init
    init(networkService: NetworkServiceProtocol, database: FirebaseDatabaseProtocol)
    // Methods
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    //Guest check-in/out methods
    func oneGuestEntered(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ())
    func canselAllTheGuestCheckins(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ())
    // Gift methods
    func presentOneGift(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ())
    func ungiftAllTheGifts(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ())
    // Other methods
    func updateGuestData(event: EventEntity, guest: GuestEntity, completion: @escaping (Result<GuestEntity, SheetsError>) -> ())
}

class OneGuestInteractor: OneGuestInteractorProtocol {
    //MARK: -VIPER PROTOCOL
    var networkService: NetworkServiceProtocol!
    var database: FirebaseDatabaseProtocol!
    private var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()

    //MARK: -INIT
    required init(networkService: NetworkServiceProtocol, database: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.database = database
    }
    
    //MARK: -METHODS
    //MARK: Guest check-in/out methods
    // oneGuestEntered
    func oneGuestEntered(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ()) {
        if event.isOnline {
            self.oneGuestEnteredOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        } else {
            self.oneGuestEnteredOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func oneGuestEnteredOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let newEnteredGuestAmount = String(guest.guestsEntered + 1)
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "H\(row)", data: [newEnteredGuestAmount], completionHandler: completion)
    }
    private func oneGuestEnteredOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let guestID = guest.offlineUID else {
            return
        }
        let newEnteredGuestsValue = String(guest.guestsEntered + 1)
        self.database.updateOnePropertyInGuestData(eventID: eventID, guestID: guestID, key: "guestsEntered", value: newEnteredGuestsValue, completion: completion)
    }
    // canselAllTheGuestCheckins
    func canselAllTheGuestCheckins(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ()) {
        switch event.isOnline {
        case true:
            self.canselAllTheGuestCheckinsInOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        case false:
            self.canselAllTheGuestCheckinsInOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func canselAllTheGuestCheckinsInOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "H\(row)", data: ["0"], completionHandler: completion)
    }
    private func canselAllTheGuestCheckinsInOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let guestID = guest.offlineUID else {
            return
        }
        let newEnteredGuestsValue = "0"
        self.database.updateOnePropertyInGuestData(eventID: eventID, guestID: guestID, key: "guestsEntered", value: newEnteredGuestsValue, completion: completion)
    }
    //MARK: Gift methods
    func presentOneGift(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ()) {
        switch event.isOnline {
        case true:
            self.presentGiftInOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        case false:
            self.presentGiftInOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func presentGiftInOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let newPresentedGiftsAmount = String(guest.giftsGifted + 1)
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "I\(row)", data: [newPresentedGiftsAmount], completionHandler: completion)
    }
    private func presentGiftInOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let guestID = guest.offlineUID else {
            return
        }
        let newGiftsValue = String(guest.giftsGifted + 1)
        self.database.updateOnePropertyInGuestData(eventID: eventID, guestID: guestID, key: "giftsGifted", value: newGiftsValue, completion: completion)
        
    }
    func ungiftAllTheGifts(event: EventEntity, guest: GuestEntity, completion: @escaping (String) -> ()) {
        switch event.isOnline {
        case true:
            self.ungiftAllTheGiftsInOnlineEvent(eventID: event.eventID, guest: guest, completion: completion)
        case false:
            self.ungiftAllTheGiftsInOfflineEvent(eventID: event.eventID, guest: guest, completion: completion)
        }
    }
    private func ungiftAllTheGiftsInOnlineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "I\(row)", data: ["0"], completionHandler: completion)
    }
    private func ungiftAllTheGiftsInOfflineEvent(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let guestID = guest.offlineUID else {
            return
        }
        let newGiftsValue = "0"
        self.database.updateOnePropertyInGuestData(eventID: eventID, guestID: guestID, key: "giftsGifted", value: newGiftsValue, completion: completion)
    }
    
    //MARK: -Other methods
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: stringURL, completionBlock: completion)
    }
    //MARK: updateGuestData
    func updateGuestData(event: EventEntity, guest: GuestEntity, completion: @escaping (Result<GuestEntity, SheetsError>) -> ()) {
        switch event.isOnline {
        case true:
            self.updateOnlineGuestData(eventID: event.eventID, guestRow: Int(guest.guestRowInSpreadSheet ?? "0")!, completion: completion)
        case false:
            self.updateOfflineGuestData(eventID: event.eventID, guestID: guest.offlineUID ?? "0", completion: completion)
        }
    }
    private func updateOfflineGuestData(eventID: String, guestID: String, completion: @escaping (Result<GuestEntity, SheetsError>) -> ()) {
        self.database.readOneGuestDataFromDatabase(eventID: eventID, guestID: guestID, completion: completion)
    }
    private func updateOnlineGuestData(eventID: String, guestRow: Int, completion: @escaping (Result<GuestEntity, SheetsError>) -> ()) {
        spreadsheetsServise.readSpreadsheetsData(range: .oneGuestData, eventID: eventID, oneGuestRow: String(guestRow)) { result in
            switch result {
            case .success(let oneGuestData):
                guard let guestArray = oneGuestData.first
                else {return}
                let updatedGuest = GuestEntity.createGuestEntityWith(guestStringArray: guestArray, row: guestRow)
                completion(.success(updatedGuest))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
