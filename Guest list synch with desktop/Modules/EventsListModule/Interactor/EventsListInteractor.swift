//
//  LoggedInInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit

protocol EventsListInteractorProtocol {
    //VIPER protocol
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol {get set}
    //Spreadsheet methods
    func readAllTheEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void)
}

enum EventListInteractorError: Error {
    case parceError
    case spreadsheetsServiceError
    case noEventsToShow
}

class EventsListInteractor: EventsListInteractorProtocol {
    
    //MARK: -VIPER protocol
    internal var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    
    //MARK: -Spreadsheets methods
    func readAllTheEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        // temp properties
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "concurrent", qos: .userInteractive, attributes: .concurrent)
        var userEventEntities = Array<EventEntity>()
        concurrentQueue.async() {
            // get user events ids
            guard let userEventIdList = FirebaseService.logginnedUser?.eventsIdList else {
                completionHandler(.failure(.noEventsToShow))
                return
            }
            // download and create entites all the user events
            for eventID in userEventIdList {
                group.enter()
                self.spreadsheetsServise.readSpreadsheetsData(range: .oneEventData, eventID: eventID) { result in
                    switch result {
                    case .success(let eventsDataAsStringsArray):
                        //TODO: проверки чтобы не было пустых массивов
                        let eventName = eventsDataAsStringsArray[2][0]
                        let clientName = eventsDataAsStringsArray[4][0]
                        let venueName = eventsDataAsStringsArray[6][0]
                        let eventDate = eventsDataAsStringsArray[8][0]
                        let eventTime = eventsDataAsStringsArray[10][0]
                        let totalGuests = eventsDataAsStringsArray[12][0]
                        let totalCheckedInGuests = eventsDataAsStringsArray[14][0]
                        let totalGiftsGaved = eventsDataAsStringsArray[16][0]
                        let initedByUserUID = eventsDataAsStringsArray[18][0]
                        let initedByUserName = eventsDataAsStringsArray[20][0]
                        
                        let oneEvent = EventEntity(eventName: eventName,
                                                   eventClient: clientName,
                                                   eventVenue: venueName,
                                                   eventDate: eventDate,
                                                   eventTime: eventTime,
                                                   totalGuest: totalGuests,
                                                   totalCheckedInGuests: totalCheckedInGuests,
                                                   totalGiftsGaved: totalGiftsGaved,
                                                   eventUniqueIdentifier: eventID,
                                                   initedByUserUID: initedByUserUID,
                                                   initedByUserName: initedByUserName)
                        userEventEntities.append(oneEvent)
                    case .failure(_):
                        completionHandler(.failure(.spreadsheetsServiceError))
                    }
                    group.leave()
                }
            }
            print(Thread.current)
            group.wait()
            if userEventEntities.isEmpty {
                completionHandler(.failure(.noEventsToShow))
            } else {
                completionHandler(.success(userEventEntities))
            }
        }
    }
    
    
    
}
