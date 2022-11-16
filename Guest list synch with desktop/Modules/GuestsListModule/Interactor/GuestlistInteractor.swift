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
                            let oneEmptyGuest = GuestEntity()
                            guestsArrayEntity.append(oneEmptyGuest)
                            rowCounter += 1
                        } else {
                            let oneGuest = self.createGuestEntityWith(guestStringArray: guestStringArray, row: rowCounter)
                            guestsArrayEntity.append(oneGuest)
                            rowCounter += 1
                        }
                    }
                case .failure(_):
                    completion(.failure(.spreadsheetsServiceError))
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
}
