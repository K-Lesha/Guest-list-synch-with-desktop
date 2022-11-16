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
    // Init
    init(networkService: NetworkServiceProtocol)
    // Methods
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    //Guest check-in/out methods
    func oneGuestEntered(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ())
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
    private var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()

    //MARK: -INIT
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    //MARK: -METHODS
    //MARK: Guest check-in/out methods
    func oneGuestEntered(eventID: String, guest: GuestEntity, completion: @escaping (String) -> ()) {
        guard let row = guest.guestRowInSpreadSheet else {
            //completion false
            return
        }
        let newEnteredGuestAmount = String(guest.guestsEntered + 1)
        self.spreadsheetsServise.sendDataToCell(spreadsheetID: eventID, range: "H\(row)", data: [newEnteredGuestAmount], completionHandler: completion)
    }
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
                let updatedGuest = self.createGuestEntityWith(guestStringArray: guestArray, row: guestRow)
                completion(.success(updatedGuest))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func createGuestEntityWith(guestStringArray: [String], row: Int) -> GuestEntity {
        //TODO: перетащить этот метод в гэст энтити
        var oneGuest = GuestEntity()
        for (index, guestData) in guestStringArray.enumerated() {
            switch index {
            case 0:
                oneGuest.guestName = guestData
            case 1:
                oneGuest.guestSurname = guestData
            case 2:
                oneGuest.companyName = guestData
            case 3:
                oneGuest.positionInCompany = guestData
            case 4:
                oneGuest.guestGroup = guestData
            case 5:
                oneGuest.guestsAmount = Int(guestData)!
            case 6:
                oneGuest.guestsEntered = Int(guestData)!
            case 7:
                oneGuest.giftsGifted = Int(guestData)!
            case 8:
                oneGuest.photoURL = guestData
            case 9:
                oneGuest.phoneNumber = guestData
            case 10:
                oneGuest.guestEmail = guestData
            case 11:
                oneGuest.internalNotes = guestData
            case 12:
                oneGuest.additionDate = guestData
            default:
                break
            }
            oneGuest.guestRowInSpreadSheet = String(row)
            oneGuest.empty = false
        }
        return oneGuest
    }
    
    
}
