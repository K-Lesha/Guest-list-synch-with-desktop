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
    //init
    init(firebaseService: FirebaseServiceProtocol)
    //Spreadsheet methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void)
    func checkGoogleSignIn(completion: @escaping (Bool) -> ())
    func updateEventEntity(eventID: String, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ())
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
    
    //MARK: INIT
    required init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }

    //MARK: -Spreadsheets methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {
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
                            let oneGuest = self.createGuestEntityWith(guestStringArray: guestStringArray, row: rowCounter)
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
    func createGuestEntityWith(guestStringArray: [String], row: Int) -> GuestEntity {
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
    func checkGoogleSignIn(completion: @escaping (Bool) -> ()) {
        firebaseService.checkSignInWithGoogle(completion: completion)
    }
    func updateEventEntity(eventID: String, completion: @escaping (Result<EventEntity, GuestlistInteractorError>) -> ()) {
        spreadsheetsServise.readSpreadsheetsData(range: .oneEventData, eventID: eventID, oneGuestRow: nil) { result in
            switch result {
            case .success(let eventStringArray):
                var updatedEventEntity = self.createEventEntityWith(eventStringArray: eventStringArray)
                updatedEventEntity.eventUniqueIdentifier = eventID
                completion (.success(updatedEventEntity))
            case .failure(_):
                completion(.failure(.spreadsheetsServiceError))
            }
        }
    }
    
    private func createEventEntityWith(eventStringArray: [[String]]) -> EventEntity {
        //TODO: перенести этот метод в энтити
        var oneEvent = EventEntity()
        for (index, eventData) in eventStringArray.enumerated() {
            switch index {
            case 0:
                oneEvent.eventName = eventData.first ?? "event without name"
            case 2:
                oneEvent.eventClient = eventData.first ?? "no client data"
            case 4:
                oneEvent.eventVenue = eventData.first ?? "no venue data"
            case 6:
                oneEvent.eventDate = eventData.first ?? "unknown event date"
            case 8:
                oneEvent.eventTime = eventData.first ?? "unknown event time"
            case 10:
                oneEvent.totalGuest = eventData.first ?? "no info"
            case 12:
                oneEvent.totalCheckedInGuests = eventData.first ?? "no info"
            case 14:
                oneEvent.totalGiftsGaved = eventData.first ?? "no info"
            case 16:
                oneEvent.initedByUserUID = eventData.first ?? "no info"
            case 18:
                oneEvent.initedByUserName = eventData.first ?? "no info"
            default:
                break
            }
        }
        return oneEvent
    }
}
