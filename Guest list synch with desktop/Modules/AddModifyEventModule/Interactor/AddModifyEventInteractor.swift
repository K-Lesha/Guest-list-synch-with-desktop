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
    //Spreadsheet methods
    func addNewEvent(eventName: String,
                     eventVenue: String?,
                     eventDate: String,
                     eventTime: String?,
                     eventClient: String?,
                     isOnline: Bool,
                     completion: @escaping (Result<String, FirebaseDatabaseError>) -> ()) 
    func modifyEvent(eventID: String, newEventData: EventEntity, completion: @escaping (String) -> ())
    func deleteEvent(eventID: String, completion: @escaping (String) -> ())
}

enum AddModifyEventEnteractorError: Error {
    case error
}

class AddModifyEventInteractor: AddModifyEventInteractorProtocol {
    
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    var networkService: NetworkServiceProtocol!
    var firebaseDatabase: FirebaseDatabaseProtocol!
    
    let operationQueue = OperationQueue()
    
    required init(networkService: NetworkServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseDatabase = firebaseDatabase
    }
    
    
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
//        let emptyOfflineEvent = EventEntity.createEmptyOfflineEvent(eventName: eventName,
//                                                                    eventClient: eventClient,
//                                                                    eventVenue: eventVenue,
//                                                                    eventDate: eventDate,
//                                                                    eventTime: eventTime,
//                                                                    userUID: user.uid,
//                                                                    userName: user.name)
        let emptyOfflineEvent = EventEntity.createDemoOfflineEvent(userUID: user.uid, userName: user.name)
            
        //2. Send it to database
        firebaseDatabase.setOfflineEventToDatabase(event: emptyOfflineEvent) { result in
            switch result {
            case .success(_):
                //3. synch current user in the app with cloud database data
                self.firebaseDatabase.updateUserData {
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
        //1. spreadsheet service creates new spreadsheed and gives eventID in completion
        spreadsheetsServise.createDefaultSpreadsheet(named: eventName + " GUESTLIST", sheetType: .emptyEvent) { eventID in
            self.operationQueue.addOperation {
                //2. filling event spreadsheet with the nececcery data
                let eventData: [[String]] = [[eventName],
                                             ["Клиент"], [eventClient ?? " "],
                                             ["Площадка"], [eventVenue ?? " "],
                                             ["Дата"], [eventDate],
                                             ["Время"], [eventTime ?? " "]]
                guard let user = FirebaseService.logginnedUser else { return }
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
            self.operationQueue.addOperation {
                AddModifyEventSemaphore.shared.wait()
                AddModifyEventSemaphore.shared.wait()
                self.firebaseDatabase.setNewOnlineEventIDInDatabase(eventID: eventID) {_ in
                    //4. synch current user in the app with cloud database data
                    self.firebaseDatabase.updateUserData {
                        DispatchQueue.main.async {
                            //5. sending completion to the UI
                            completion(.success("success"))
                        }
                    }
                }
            }
        }
    }
    
    func modifyEvent(eventID: String, newEventData: EventEntity, completion: @escaping (String) -> ()) {
        let newEventData: [[String]] = [[newEventData.eventName],
                                        ["Клиент"], [newEventData.eventClient],
                                        ["Площадка"], [newEventData.eventVenue],
                                        ["Дата"], [newEventData.eventDate],
                                        ["Время"], [newEventData.eventTime]]
        spreadsheetsServise.sendBlockOfDataToCell(spreadsheetID: eventID, range: "A3:A11", data: newEventData, completionHandler: completion)
    }
    
    func deleteEvent(eventID: String, completion: @escaping (String) -> ()) {
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
            self.firebaseDatabase.updateUserData {
                //4. sending completion to the UI
                completion("success")
            }
        }
    }
}
