//
//  GoogleSpreadsheetsService.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 27.10.2022.
//

import Foundation
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST

import FirebaseAuth
import FirebaseCore

//MARK: -protocol GoogleSpreadsheetsServiceProtocol
protocol GoogleSpreadsheetsServiceProtocol {
    //Methods
    func readSpreadsheetsData(range: SheetsRange, eventID: String, oneGuestRow: String?, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void)
    func appendData(spreadsheetID: String, range: SheetsRange, data: [String], completion: @escaping (String) -> Void)
    func sendDataToCell(spreadsheetID: String, range: String, data: [String], completionHandler: @escaping (String) -> Void)
    func sendBlockOfDataToCell(spreadsheetID: String, range: String, data: [[String]], completionHandler: @escaping (String) -> Void)
    func createDefaultSpreadsheet(named name: String, sheetType: DefaultSheetsIds, completion: @escaping (String) -> ())
}
//MARK: -SheetsRange
enum SheetsRange: String {
    case oneEventData = "A3:A21"
    case oneEventDataForFilling = "A3"
    case guestsDataForReading = "B25:N"
    case guestsDataForAdding = "A25:N"
    case oneGuestData = "B"
}
//MARK: -DefaultSheetsIds
enum DefaultSheetsIds: String {
    case demoEvent = "1OlZ7J45qI3zE9ViWcpgc5ZCmhPWdpgh8rlABjTy3dWk"
    case emptyEvent = "1RRZ6QRAguHYu1rmOwcdAKJUZbWi14RASlUv1_Rbd42I"
}

//MARK: -SheetsError
enum SheetsError: Error {
    case error
    case dataIsEmpty
}
//MARK: -GoogleSpreadsheetsService
class GoogleSpreadsheetsService: GoogleSpreadsheetsServiceProtocol {
    //Service properties & data
    private let sheetService = GTLRSheetsService()
    let apiKey = "AIzaSyDmUVpnjFI_cKazeKORNk37o-MV_prH970"
    static let grantedScopes = "https://www.googleapis.com/auth/spreadsheets"
    static let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets",
                                   "https://www.googleapis.com/auth/drive.file"]
    
    //Service init
    init() {
        sheetService.apiKey = self.apiKey
        updateServiceAuthorizer()
    }
    
    //MARK: -Methods
    //service methods
    func updateServiceAuthorizer() {
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }
    //Spreadsheets methods
    func readSpreadsheetsData(range: SheetsRange, eventID: String, oneGuestRow: String?, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void) {
        print("Getting sheet data...")
        updateServiceAuthorizer()
        var rangeRawValue = range.rawValue
        if range == .oneGuestData {
            rangeRawValue += oneGuestRow! + ":N" + oneGuestRow!
        }
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: eventID, range: rangeRawValue)
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error {
                print("Google sheets service: ", error.localizedDescription)
                completionHandler(.failure(.error))
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                completionHandler(.failure(.error))
                return
            }
            guard let stringRows = result.values as? [[String]] else {
                completionHandler(.failure(.dataIsEmpty))
                return
            }
            
            if stringRows.isEmpty {
                completionHandler(.failure(.dataIsEmpty))
                return
            }
            completionHandler(.success(stringRows))
        }
    }
    
    
    func appendData(spreadsheetID: String, range: SheetsRange, data: [String], completion: @escaping (String) -> Void) {
        updateServiceAuthorizer()
        let rangeToAppend = GTLRSheets_ValueRange.init();
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetID, range: range.rawValue)
        query.valueInputOption = "USER_ENTERED"
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error in appending data: \(error)")
                completion("Error in sending data:\n\(error.localizedDescription)")
            } else {
                print("Data sent: \(data)")
                completion("Success!")
            }
        }
    }
    
    func sendDataToCell(spreadsheetID: String, range: String, data: [String], completionHandler: @escaping (String) -> Void) {
        
        let rangeToAppend = GTLRSheets_ValueRange.init();
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetID, range: range)
        //row = Any range on the sheet, for instance: "A5:B6"
        query.valueInputOption = "USER_ENTERED"
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Error in sending data:\n\(error.localizedDescription)")
            } else {
                print("Sending: \(data)")
                completionHandler("Sucess!")
            }
        }
    }
    
    func sendBlockOfDataToCell(spreadsheetID: String, range: String, data: [[String]], completionHandler: @escaping (String) -> Void) {
        
        let rangeToAppend = GTLRSheets_ValueRange.init();
        rangeToAppend.values = data
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetID, range: range)
        //row = Any range on the sheet, for instance: "A5:B6"
        query.valueInputOption = "USER_ENTERED"
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Error in sending data:\n\(error.localizedDescription)")
            } else {
                print("Sending: \(data)")
                completionHandler("Sucess!")
            }
        }
    }

    
    
    //MARK: -ADD NEW SPREADSHEET WITH (DEMO/EMPTY)EVENT
    public func createDefaultSpreadsheet(named name: String, sheetType: DefaultSheetsIds, completion: @escaping (String) -> ()) {
        updateServiceAuthorizer()
        let newSheet = GTLRSheets_Spreadsheet.init()
        let properties = GTLRSheets_SpreadsheetProperties.init()
        properties.title = name
        newSheet.properties = properties
        
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
        query.fields = "spreadsheetId"
        
        query.completionBlock = { (ticket, result, error) in
            
            if let error {
                print(error.localizedDescription)
                completion(error.localizedDescription)
            }
            else {
                let response = result as! GTLRSheets_Spreadsheet
                let identifier = response.spreadsheetId
                self.copyDefaultSheetTo(spreadsheet: identifier!, sheetType: sheetType, completion: completion)
                
            }
        }
        sheetService.executeQuery(query, completionHandler: nil)
    }
    private func copyDefaultSheetTo(spreadsheet spreadsheetID: String, sheetType: DefaultSheetsIds, completion: @escaping (String) -> ()) {
        let request = GTLRSheets_CopySheetToAnotherSpreadsheetRequest()
        request.destinationSpreadsheetId = spreadsheetID
        
        let query = GTLRSheetsQuery_SpreadsheetsSheetsCopyTo.query(withObject: request, spreadsheetId: sheetType.rawValue, sheetId: 0)
        
        query.completionBlock =  { (ticket, result, error) in
            if let error {
                completion(error.localizedDescription)
            }
            else {
                self.deleteFirstEmtySheetIn(spreadsheet: spreadsheetID, completion: completion)
            }

        }
        sheetService.executeQuery(query)
    }
    private func deleteFirstEmtySheetIn(spreadsheet spreadsheetID: String, completion: @escaping (String) -> ()) {
        let deleteSheetRequest = GTLRSheets_DeleteSheetRequest()
        deleteSheetRequest.sheetId = 0
        let sheetRequest = GTLRSheets_Request()
        sheetRequest.deleteSheet = deleteSheetRequest
        let batchUpdateRequest = GTLRSheets_BatchUpdateSpreadsheetRequest()
        batchUpdateRequest.requests = [sheetRequest]
        
        let query = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdateRequest, spreadsheetId: spreadsheetID)
        query.completionBlock =  { (ticket, result, error) in
            if let error {
                completion(error.localizedDescription)
            }
            else {
                completion(spreadsheetID)
            }
        }
        sheetService.executeQuery(query)
    }
//    private func getSheetsIDsAndRenameIn(spreadsheet spreadsheetID: String, completion: @escaping (String) -> ()) {
//        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetID)
//
//        query.completionBlock =  { (ticket, result, error) in
//            if let error {
//                completion(error.localizedDescription)
//            }
//            else {
//                let spreadsheet = result as? GTLRSheets_Spreadsheet
//                let sheets = spreadsheet?.sheets
//                for sheet in sheets! {
//                    self.renameSheetIn(spreadsheet: spreadsheetID, sheetID: sheet.properties!.sheetId!, completion: completion)
//                }
//            }
//        }
//        sheetService.executeQuery(query)
//    }
    
//    private func renameSheetNameIn(spreadsheet spreadsheetID: String, sheetID: NSNumber, completion: @escaping (String) -> ()) {
//
//        let renameSheetRequest = GTLRSheets_UpdateSheetPropertiesRequest()
//        renameSheetRequest.properties?.sheetId = sheetID
//        renameSheetRequest.properties?.title = "GUESTLIST"
//        renameSheetRequest.fields = "title"
//
//        let sheetRequest = GTLRSheets_Request()
//        sheetRequest.updateSheetProperties = renameSheetRequest
//
//        let batchUpdateRequest = GTLRSheets_BatchUpdateSpreadsheetRequest()
//        batchUpdateRequest.requests = [sheetRequest]
//
//        let query = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdateRequest, spreadsheetId: spreadsheetID)
//        query.completionBlock =  { (ticket, result, error) in
//            if let error {
//                completion(error.localizedDescription)
//            }
//            else {
//                completion(spreadsheetID)
//            }
//        }
//        sheetService.executeQuery(query)
//    }
    
    
    
}
