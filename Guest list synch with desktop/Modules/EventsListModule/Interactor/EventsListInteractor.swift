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
    var networkService: NetworkServiceProtocol! {get set}
    init (networkService: NetworkServiceProtocol)
    //Spreadsheet methods
    func readOneEventData(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void)
}

enum EventListInteractorError: Error {
    case parceError
    case spreadsheetsServiceError
}

class EventsListInteractor: EventsListInteractorProtocol {
    
    //MARK: VIPER protocol
    internal var networkService: NetworkServiceProtocol!
    internal var spreadsheetsServise = GoogleSpreadsheetsService()

        
    internal required init (networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Spreadsheets methods
    func readOneEventData(completionHandler: @escaping (Result<[EventEntity], EventListInteractorError>) -> Void) {
        OperationQueue().addOperation {
            EventsListSemaphore.shared.wait()
            self.spreadsheetsServise.readOneEventData(range: .oneEventData) { result in
                switch result {
                case .success(let stringsArray):
                    do {
                        let eventName = stringsArray[1][0]
                        let clientName = stringsArray[3][0]
                        let venueName = stringsArray[5][0]
                        let eventDate = stringsArray[7][0]
                        let eventTime = stringsArray[9][0]
                        let uniqueIdentifier = stringsArray[11][0]
                        
                        let oneEvent = EventEntity(eventName: eventName,
                                                   eventClient: clientName,
                                                   eventVenue: venueName,
                                                   eventDate: eventDate,
                                                   eventTime: eventTime,
                                                   eventUniqueIdentifier: uniqueIdentifier)
                        completionHandler(.success([oneEvent]))
                    } catch {
                        completionHandler(.failure(.parceError))
                    }
                case .failure(_):
                    completionHandler(.failure(.spreadsheetsServiceError))
                }
            }
        }
    }

}
