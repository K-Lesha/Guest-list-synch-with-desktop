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
    var firebaseDatabase: FirebaseDatabaseProtocol! {get set}
    //INIT
    init(firebaseDatabase: FirebaseDatabaseProtocol)
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
    var firebaseDatabase: FirebaseDatabaseProtocol!
    
    //MARK: INIT
    required init(firebaseDatabase: FirebaseDatabaseProtocol) {
        self.firebaseDatabase = firebaseDatabase
    }

    //MARK: -Spreadsheets methods
    func readAllTheEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        
        let group = DispatchGroup()
        
        var eventsArray = [EventEntity]()

        group.enter()
        DispatchQueue.global().async {
            self.readOnlineEvents() { result in
                switch result {
                case .success(let spreadsheetsEventsArray):
                    eventsArray.append(contentsOf: spreadsheetsEventsArray)
                    group.leave()
                case .failure(_):
                    print("EventsListInteractor readOnlineEvents error")
                    group.leave()
                }
            }
        }

        group.enter()
        readOfflineEvents() { result in
            switch result {
            case .success(let offlineEventsArray):
                eventsArray.append(contentsOf: offlineEventsArray)
                group.leave()
            case .failure(_):
                print("EventsListInteractor readOfflineEvents error")
                group.leave()
            }
        }
        
        DispatchQueue.global().async {
            group.wait()
            DispatchQueue.main.async {
                completionHandler(.success(eventsArray))
            }
        }
    }
    
    func readOnlineEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        // temp properties
        let group = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "concurrent", qos: .userInteractive, attributes: .concurrent)
        var userEventEntities = Array<EventEntity>()
        concurrentQueue.async() {
            // get user events ids
            guard let userEventIdList = FirebaseService.logginnedUser?.onlineEventsIDList else {
                completionHandler(.failure(.noEventsToShow))
                return
            }
            // download and create entites all the user events
            for eventID in userEventIdList {
                group.enter()
                self.spreadsheetsServise.readSpreadsheetsData(range: .oneEventData, eventID: eventID, oneGuestRow: nil) { result in
                    switch result {
                    case .success(let eventDataStringsArray):
                        let oneEvent = EventEntity.createOnlineEventEntityWith(eventStringArray: eventDataStringsArray, eventID: eventID)
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
    
    
    func readOfflineEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        if let events = FirebaseService.logginnedUser?.offlineEvents {
            completionHandler(.success(events))
        } else {
            completionHandler(.failure(.noEventsToShow))
        }
    }
    
    
}
