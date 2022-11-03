//
//  GuestlistInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import Foundation

protocol GuestlistInteractorProtocol {
    //VIPER protocol
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol {get set}
    //Spreadsheet methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void)
    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
}

enum GuestlistInteractorError: Error {
    case error
    case wrongEventID
    case spreadsheetsServiceError
    case noGuestsToShow
}

class GuestListInteractor: GuestlistInteractorProtocol {
    
    //MARK: -VIPER protocol
    internal var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    
    //MARK: -Spreadsheets methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {
        // temp properties
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "concurrent", qos: .userInteractive, attributes: .concurrent)
        var guestsArrayEntity = Array<GuestEntity>()
        concurrentQueue.async() {
            // download and create entites all the event guests
            group.enter()
            self.spreadsheetsServise.readSpreadsheetsData(range: .guestsDataForReading, eventID: eventID) { result in
                switch result {
                case .success(let guestsDataAsStringsArray):
                    for guestStringArray in guestsDataAsStringsArray {
                        if guestStringArray.isEmpty {
                            let oneEmptyGuest = GuestEntity()
                            guestsArrayEntity.append(oneEmptyGuest)
                        } else {
                            let oneGuest = self.createGuestEntityWith(guestStringArray: guestStringArray)
                            guestsArrayEntity.append(oneGuest)
                        }
                    }
                case .failure(_):
                    completion(.failure(.spreadsheetsServiceError))
                }
                group.leave()
            }
            
            print(Thread.current)
            group.wait()
            if guestsArrayEntity.isEmpty {
                completion(.failure(.noGuestsToShow))
            } else {
                completion(.success(guestsArrayEntity))
            }
        }
    }
    func createGuestEntityWith(guestStringArray: [String]) -> GuestEntity {
        var oneGuest = GuestEntity()
        for (index, guestData) in guestStringArray.enumerated() {
            switch index {
            case 0:
                oneGuest.guestName = guestData
            case 1:
                oneGuest.guestSurname = guestData
            default:
                break
            }
        }
        return oneGuest
    }
    
    func addNewGuest(eventID: String, guest: GuestEntity, completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        self.spreadsheetsServise.appendData(spreadsheetID: eventID, range: .guestsDataForAdding, data: ["n",guest.guestName, guest.guestSurname]) { string in
            print(string)
            completion(.success(true))
        }
        
        
        
    }
}
