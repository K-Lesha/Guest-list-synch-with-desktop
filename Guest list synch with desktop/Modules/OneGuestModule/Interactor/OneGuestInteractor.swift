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
    func canselAllTheGuestCheckins(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ())
    // Gift methods
    func presentOneGift(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ())
    func ungiftAllTheGifts(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ())
    // Other methods
    func updateGuestData(eventID: String, guest: GuestEntity, completion: @escaping (Result<GuestEntity, SheetsError>) -> ())
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
        //TODO: HERE
    }
    // canselAllTheGuestCheckins
    func canselAllTheGuestCheckins(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "H\(row)", data: ["0"], completionHandler: completion)
    }
    
    //MARK: Gift methods
    func presentOneGift(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let newPresentedGiftsAmount = String(guest.giftsGifted + 1)
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "I\(row)", data: [newPresentedGiftsAmount], completionHandler: completion)
    }
    func ungiftAllTheGifts(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "I\(row)", data: ["0"], completionHandler: completion)
    }
    
    //MARK: Other methods
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: stringURL, completionBlock: completion)
    }
    func updateGuestData(eventID: String, guest: GuestEntity, completion: @escaping (Result<GuestEntity, SheetsError>) -> ()) {
        spreadsheetsServise.readSpreadsheetsData(range: .oneGuestData, eventID: eventID, oneGuestRow: guest.guestRowInSpreadSheet) { result in
            switch result {
            case .success(let oneGuestData):
                guard let guestArray = oneGuestData.first,
                      let guestRow = Int(guest.guestRowInSpreadSheet!)
                else {return}
                let updatedGuest = GuestEntity.createGuestEntityWith(guestStringArray: guestArray, row: guestRow)
                completion(.success(updatedGuest))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
