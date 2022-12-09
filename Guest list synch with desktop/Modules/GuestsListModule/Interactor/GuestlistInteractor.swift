//
//  GuestlistInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import Foundation

protocol GuestlistInteractorProtocol {
    //VIPER protocol
    var firebaseService: FirebaseServiceProtocol! {get set}
    var database: FirebaseDatabaseProtocol! {get set}
    //init
    init(firebaseService: FirebaseServiceProtocol, database: FirebaseDatabaseProtocol)
    //Spreadsheet methods
    func readEventGuests(event: EventEntity, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void)
    func checkGoogleSignIn(completion: @escaping (Bool) -> ())
    func updateEventEntity(eventEntity: EventEntity, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ())
}

enum GuestlistInteractorError: Error {
    case error
    case wrongEventID
    case spreadsheetsServiceError
    case noGuestsToShow
}

class GuestListInteractor: GuestlistInteractorProtocol {

    //MARK: -VIPER protocol
    private var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    internal var firebaseService: FirebaseServiceProtocol!
    internal var database: FirebaseDatabaseProtocol!
    
    //MARK: INIT
    required init(firebaseService: FirebaseServiceProtocol, database: FirebaseDatabaseProtocol) {
        self.firebaseService = firebaseService
        self.database = database
    }

    //MARK: -Spreadsheets methods
    //readEventGuests
    func readEventGuests(event: EventEntity, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {
        if event.isOnline {
            readOnlineEventGuests(eventID: event.eventID, completion: completion)
        } else {
            readOfflineEvent(event: event, completion: completion)
        }
    }
    private func readOnlineEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {
        // temp properties
        //TODO: make an operation queue with completion
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "concurrent", qos: .userInteractive, attributes: .concurrent)
        var guestsArrayEntity = Array<GuestEntity>()
        concurrentQueue.async() {
            // download and create entites all the event guests
            group.enter()
            self.spreadsheetsServise.readSpreadsheetsData(range: .guestsDataForReading, eventID: eventID, oneGuestRow: nil) { result in
                switch result {
                case .success(let guestsDataAsStringsArray):
                    var rowCounter = 25
                    for guestStringArray in guestsDataAsStringsArray {
                        if guestStringArray.isEmpty {
                            var oneEmptyGuest = GuestEntity()
                            oneEmptyGuest.guestRowInSpreadSheet = String(rowCounter)
                            guestsArrayEntity.append(oneEmptyGuest)
                            rowCounter += 1
                        } else {
                            let oneGuest = GuestEntity.createGuestEntityWith(guestStringArray: guestStringArray, row: rowCounter)
                            guestsArrayEntity.append(oneGuest)
                            rowCounter += 1
                        }
                    }
                case .failure(let error):
                    if error == .dataIsEmpty {
                        completion(.failure(.noGuestsToShow))
                    } else {
                        completion(.failure(.spreadsheetsServiceError))
                    }
                }
                group.leave()
            }
            group.wait()
            if guestsArrayEntity.isEmpty {
                completion(.failure(.noGuestsToShow))
            } else {
                completion(.success(guestsArrayEntity))
            }
        }
    }
    private func readOfflineEvent(event: EventEntity, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {
        if let guestEntities = event.guestsEntites {
            completion(.success(guestEntities))
        } else {
            completion(.failure(.noGuestsToShow))
        }
    }
    //checkGoogleSignIn
    func checkGoogleSignIn(completion: @escaping (Bool) -> ()) {
        firebaseService.loginedWithGoogleCheck(completion: completion)
    }
    //Update event entity
    func updateEventEntity(eventEntity: EventEntity, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ()) {
        if eventEntity.isOnline {
            self.updateOnlineEventEntity(eventID: eventEntity.eventID, completion: completion)
        } else {
            self.updateOfflineEventEntity(eventID: eventEntity.eventID, completion: completion)
        }
    }
    private func updateOnlineEventEntity(eventID: String, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ()) {
        spreadsheetsServise.readSpreadsheetsData(range: .oneEventData, eventID: eventID, oneGuestRow: nil) { result in
            switch result {
            case .success(let eventStringArray):
                let updatedEventEntity = EventEntity.createOnlineEventEntityWith(eventStringArray: eventStringArray, eventID: eventID)
                completion (.success(updatedEventEntity))
            case .failure(_):
                completion(.failure(.spreadsheetsServiceError))
            }
        }
    }
    private func updateOfflineEventEntity(eventID: String, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ()) {
        self.database.readOneOfflineEventFromDatabase(offlineEventID: eventID) { result in
            switch result {
            case .success(let eventDictionary):
                let event = EventEntity.createOneOfflineEventFrom(eventDictionary)
                completion(.success(event))
            case .failure(_):
                completion(.failure(.error))
            }
        }
    }
}
