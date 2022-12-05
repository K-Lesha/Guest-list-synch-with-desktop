//
//  AddModifyEventInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 16.11.2022.
//

import Foundation

protocol AddModifyEventInteractorProtocol {
    //VIPER protocol
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol {get set}
    var networkService: NetworkServiceProtocol! {get set}
    var firebaseDatabase: FirebaseDatabaseProtocol! {get set}
    //init
    init(networkService: NetworkServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol)
    //Methods
    func addNewEvent(eventName: String,
                     eventVenue: String?,
                     eventDate: String,
                     eventTime: String?,
                     eventClient: String?,
                     isOnline: Bool,
                     completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) 
    func modifyEvent(eventEntity: EventEntity, newEventData: EventEntity, completion: @escaping (String) -> ())
    func deleteEvent(eventEntity: EventEntity, completion: @escaping (String) -> ())
}

enum AddModifyEventEnteractorError: Error {
    case error
}

class AddModifyEventInteractor: AddModifyEventInteractorProtocol {
    
    //MARK: -PROTOCOL & PROPERTIES
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    var networkService: NetworkServiceProtocol!
    var firebaseDatabase: FirebaseDatabaseProtocol!
    let operationQueue = OperationQueue()
    
    //MARK: - INIT
    required init(networkService: NetworkServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseDatabase = firebaseDatabase
    }
    
    //MARK: -METHODS
    //MARK: Add event methods
    func addNewEvent(eventName: String,
                     eventVenue: String?,
                     eventDate: String,
                     eventTime: String?,
                     eventClient: String?,
                     isOnline: Bool,
                     completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        if isOnline {
            addNewOnlineEvent(eventName: eventName, eventVenue: eventVenue, eventDate: eventDate, eventTime: eventTime, eventClient: eventClient, completion: completion)
        } else {
            addNewOfflineEvent(eventName: eventName, eventVenue: eventVenue, eventDate: eventDate, eventTime: eventTime, eventClient: eventClient, completion: completion)
        }
    }
    func addNewOfflineEvent(eventName: String,
                            eventVenue: String?,
                            eventDate: String,
                            eventTime: String?,
                            eventClient: String?,
                            completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        guard let user = FirebaseService.logginnedUser else {
            return
        }
        //1. Add emptyEventEntity
        let emptyOfflineEvent = EventEntity.createEmptyOfflineEvent(eventName: eventName,
                                                                    eventClient: eventClient,
                                                                    eventVenue: eventVenue,
                                                                    eventDate: eventDate,
                                                                    eventTime: eventTime,
                                                                    userUID: user.uid,
                                                                    userName: user.name)
        //2. Send it to database
        firebaseDatabase.addOfflineEventToUserDatabase(event: emptyOfflineEvent) { result in
            switch result {
            case .success(_):
                //3. synch current user in the app with cloud database data
                self.firebaseDatabase.updateUserDataInTheApp {
                    DispatchQueue.main.async {
                        //4. sending completion to the UI
                        completion(.success("success"))
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    //4. sending completion to the UI
                    completion(.failure(.error))
                }
            }
        }
    }
    func addNewOnlineEvent(eventName: String,
                           eventVenue: String?,
                           eventDate: String,
                           eventTime: String?,
                           eventClient: String?,
                           completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) {
        //TODO: обработка ошибок
        guard let user = FirebaseService.logginnedUser else { return }
        //1. spreadsheet service creates new spreadsheed and gives eventID in completion
        spreadsheetsServise.createDefaultSpreadsheet(named: eventName + " GUESTLIST", sheetType: .emptyEvent) { eventID in
            let operation = BlockOperation {
                //2. filling event spreadsheet with the nececcery data
                let eventData: [[String]] = [[eventName],
                                             ["Клиент"], [eventClient ?? " "],
                                             ["Площадка"], [eventVenue ?? " "],
                                             ["Дата"], [eventDate],
                                             ["Время"], [eventTime ?? " "]]
                
                let userData: [[String]] = [[user.uid],
                                            ["Мероприятие инициировано пользователем, имя:"], [user.name]]
                self.spreadsheetsServise.sendBlockOfDataToCell(spreadsheetID: eventID, range: "A3:A11", data: eventData) { successAdditionData1 in
                    AddModifyEventSemaphore.shared.signal()
                }
                self.spreadsheetsServise.sendBlockOfDataToCell(spreadsheetID: eventID, range: "A19:A21", data: userData) { successAdditionData2 in
                    AddModifyEventSemaphore.shared.signal()
                }
            }
            //3. saving new eventID to cloud database
            operation.completionBlock = {
                AddModifyEventSemaphore.shared.wait()
                AddModifyEventSemaphore.shared.wait()
                self.firebaseDatabase.setNewOnlineEventIDInDatabase(eventID: eventID) {_ in
                    //4. synch current user in the app with cloud database data
                    self.firebaseDatabase.updateUserDataInTheApp {
                        DispatchQueue.main.async {
                            //5. sending completion to the UI
                            completion(.success("success"))
                        }
                    }
                }
            }
            self.operationQueue.addOperation(operation)
        }
    }
    //MARK: Modify event methods
    func modifyEvent(eventEntity: EventEntity, newEventData: EventEntity, completion: @escaping (String) -> ()) {
        if eventEntity.isOnline {
            self.modifyOnlineEvent(eventID: eventEntity.eventID, newEventData: newEventData, completion: completion)
        } else {
            self.modifyOfflineEvent(eventID: eventEntity.eventID, newEventData: newEventData, completion: completion)
        }
    }
    private func modifyOnlineEvent(eventID: String, newEventData: EventEntity, completion: @escaping (String) -> ()) {
        let newEventData: [[String]] = [[newEventData.name],
                                        ["Клиент"], [newEventData.client],
                                        ["Площадка"], [newEventData.venue],
                                        ["Дата"], [newEventData.date],
                                        ["Время"], [newEventData.time]]
        spreadsheetsServise.sendBlockOfDataToCell(spreadsheetID: eventID, range: "A3:A11", data: newEventData, completionHandler: completion)
    }
    private func modifyOfflineEvent(eventID: String, newEventData: EventEntity, completion: @escaping (String) -> ()) {
        self.firebaseDatabase.addOfflineEventToUserDatabase(event: newEventData) { result in
            switch result {
            case .success(_):
                completion("ok")
            case .failure(_):
                completion("ne ok")
            }
        }
    }
    
    //MARK: Delete event methods
    func deleteEvent(eventEntity: EventEntity, completion: @escaping (String) -> ()) {
        if eventEntity.isOnline {
            self.deleteOnlineEvent(eventID: eventEntity.eventID, completion: completion)
        } else {
            self.deleteOfflineEvent(eventID: eventEntity.eventID, completion: completion)
        }
    }
    private func deleteOnlineEvent(eventID: String, completion: @escaping (String) -> ()) {
        self.operationQueue.addOperation {
            //1. firebase dabase event from database deletion
            self.firebaseDatabase.deleteOnlineEventIDInDatabase(eventID: eventID) { result in
                switch result {
                case .success(_):
                    //2. sending to spreadsheet info that event was deleted
                    let deletedEventData: [[String]] = [["мероприятие удалено"],
                                                        ["Клиент"], ["мероприятие удалено"],
                                                        ["Площадка"], ["мероприятие удалено"],
                                                        ["Дата"], ["мероприятие удалено"],
                                                        ["Время"], ["мероприятие удалено"]]
                    self.spreadsheetsServise.sendBlockOfDataToCell(spreadsheetID: eventID, range: "A3:A11", data: deletedEventData) {_ in
                        AddModifyEventSemaphore.shared.signal()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        self.operationQueue.addOperation {
            //3. synch current user in the app with cloud database data
            AddModifyEventSemaphore.shared.wait()
            self.firebaseDatabase.updateUserDataInTheApp {
                //4. sending completion to the UI
                completion("success")
            }
        }
    }
    private func deleteOfflineEvent(eventID: String, completion: @escaping (String) -> ()) {
        //1. firebase dabase event from database deletion
        self.operationQueue.addOperation {
            self.firebaseDatabase.deleteOfflineEventInDatabase(eventID: eventID) { _ in
                AddModifyEventSemaphore.shared.signal()
            }
        }
        //2. synch current user in the app with cloud database data
        self.operationQueue.addOperation {
            AddModifyEventSemaphore.shared.wait()
            self.firebaseDatabase.updateUserDataInTheApp {
                //3. sending completion to the UI
                completion("success")
            }
        }
    }
}
