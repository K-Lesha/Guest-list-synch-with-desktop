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
    func addNewEvent(completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ())
    func modifyEvent(eventID: String, completion: @escaping (String) -> ())
    func deleteEvent(eventID: String, completion: @escaping (String) -> ())

    
}

class AddModifyEventInteractor: AddModifyEventInteractorProtocol {
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    var networkService: NetworkServiceProtocol!
    var firebaseDatabase: FirebaseDatabaseProtocol!
    
    required init(networkService: NetworkServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.networkService = networkService
        self.firebaseDatabase = firebaseDatabase
    }
    
    func addNewEvent(completion: @escaping (Result<Bool, GuestlistInteractorError>) -> ()) {
        
    }
    
    func modifyEvent(eventID: String, completion: @escaping (String) -> ()) {
        
    }
    
    func deleteEvent(eventID: String, completion: @escaping (String) -> ()) {
        
    }
    
    
}
