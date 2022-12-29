//
//  LoggedInInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation
import UIKit

protocol EventsListInteractorProtocol {
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
    private var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    private var firebaseDatabase: FirebaseDatabaseProtocol!
    private let operationQueue = OperationQueue()
    private let dispatchGroup = DispatchGroup()
    
    //MARK: INIT
    required init(firebaseDatabase: FirebaseDatabaseProtocol) {
        self.firebaseDatabase = firebaseDatabase
    }

    //MARK: -Spreadsheets methods
    func readAllTheEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        var eventsArray = [EventEntity]()
        let readOnlineEventsBlock = BlockOperation {
            self.dispatchGroup.enter()
            self.readOnlineEvents() { result in
                switch result {
                case .success(let spreadsheetsEventsArray):
                    eventsArray.append(contentsOf: spreadsheetsEventsArray)
                case .failure(_):
                    print("EventsListInteractor readOnlineEvents error")
                }
                self.dispatchGroup.leave()
            }
        }
        let readOfflineEventsBlock = BlockOperation {
            self.dispatchGroup.enter()
            self.readOfflineEvents() { result in
                switch result {
                case .success(let offlineEventsArray):
                    eventsArray.append(contentsOf: offlineEventsArray)
                case .failure(_):
                    print("EventsListInteractor readOfflineEvents error")
                }
                self.dispatchGroup.leave()
            }
        }
        let sendCompletionBlock = BlockOperation {
            self.dispatchGroup.wait()
            DispatchQueue.main.async {
                if eventsArray.isEmpty {
                    completionHandler(.failure(.noEventsToShow))
                } else {
                    completionHandler(.success(eventsArray))
                }
            }
        }
        operationQueue.addOperations([readOnlineEventsBlock, readOfflineEventsBlock], waitUntilFinished: false)
        operationQueue.waitUntilAllOperationsAreFinished()
        operationQueue.addOperation(sendCompletionBlock)
    }
    
    func readOnlineEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        // temp properties
        let group = DispatchGroup()
//        let concurrentQueue = DispatchQueue(label: "concurrent", qos: .userInteractive, attributes: .concurrent)
        let onlineOperationQueue = OperationQueue()
        var userEventEntities = Array<EventEntity>()
        // get user events ids
        guard let userEventIdList = FirebaseService.logginnedUser?.onlineEventsIDList else {
            completionHandler(.failure(.noEventsToShow))
            return
        }
        // download and create entites all the user events
        let readOnlineEventsOperation = BlockOperation {
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
        }
        readOnlineEventsOperation.completionBlock = {
            group.wait()
            if userEventEntities.isEmpty {
                completionHandler(.failure(.noEventsToShow))
            } else {
                completionHandler(.success(userEventEntities))
            }
        }
        operationQueue.addOperation(readOnlineEventsOperation)
    }
    func readOfflineEvents(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        if let events = FirebaseService.logginnedUser?.offlineEvents {
            completionHandler(.success(events))
        } else {
            completionHandler(.failure(.noEventsToShow))
        }
    }
}
