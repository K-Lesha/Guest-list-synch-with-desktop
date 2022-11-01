//
//  GuestlistInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import Foundation

protocol GuestlistInteractorProtocol {
    //VIPER protocol
    var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol {get set}
    //Spreadsheet methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void)

}

enum GuestlistInteractorError: Error {
    case error
}

class GuestListInteractor: GuestlistInteractorProtocol {
    
    //MARK: -VIPER protocol
    internal var spreadsheetsServise: GoogleSpreadsheetsServiceProtocol = GoogleSpreadsheetsService()
    
    //MARK: -Spreadsheets methods
    func readEventGuests(eventID: String, completion: @escaping (Result<[GuestEntity], GuestlistInteractorError>) -> Void) {

        // запросить у таблиц и сгенерировать массив с гест энтити
        
        //передать в комплишн обратно гест энтити
        
    }
}
