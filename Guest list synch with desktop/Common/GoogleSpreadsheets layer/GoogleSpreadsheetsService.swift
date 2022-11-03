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

protocol GoogleSpreadsheetsServiceProtocol {
    //Methods
    func readSpreadsheetsData(range: SheetsRange, eventID: String, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void)
    func appendData(spreadsheetID: String, range: SheetsRange, data: [String], completion: @escaping (String) -> Void)
}

enum SheetsRange: String {
    case oneEventData = "A1:A23"
    case guestsDataForReading = "B27:N"
    case guestsDataForAdding = "A27:N"
}
enum SheetsError: Error {
    case error
    case dataIsEmpty
}

class GoogleSpreadsheetsService: GoogleSpreadsheetsServiceProtocol {
    //Service properties
    private let sheetService = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    
    //Service init
    init() {
        sheetService.apiKey = self.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        driveService.apiKey = self.apiKey
        driveService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }
    
    let apiKey = "AIzaSyDmUVpnjFI_cKazeKORNk37o-MV_prH970"
    static let grantedScopes = "https://www.googleapis.com/auth/drive.file"
    static let additionalScopes = ["https://www.googleapis.com/auth/drive.file"]
    
    //MARK: Spreadsheets methods
    func readSpreadsheetsData(range: SheetsRange, eventID: String, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void) {
        print("Getting sheet data...")
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: eventID, range:range.rawValue)
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
            let stringRows = result.values! as! [[String]]
            
            if stringRows.isEmpty {
                completionHandler(.failure(.dataIsEmpty))
                return
            }
            completionHandler(.success(stringRows))
        }
    }

    
    func appendData(spreadsheetID: String, range: SheetsRange, data: [String], completion: @escaping (String) -> Void) {
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

//    func sendDataToCell(completionHandler: @escaping (String) -> Void) {
//
//            let spreadsheetId = self.sheetID
//            let currentRange = "A5:B5" //Any range on the sheet, for instance: A5:B6
//            let results = ["this is a test"]
//            let rangeToAppend = GTLRSheets_ValueRange.init();
//                rangeToAppend.values = [results]
//
//            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: currentRange)
//                query.valueInputOption = "USER_ENTERED"
//
//                sheetService.executeQuery(query) { (ticket, result, error) in
//                    if let error = error {
//                        print(error)
//                        completionHandler("Error in sending data:\n\(error.localizedDescription)")
//                    } else {
//                        print("Sending: \(results)")
//                        completionHandler("Sucess!")
//                    }
//                }
//    }
//
//
//    func readSheets(completionHandler: @escaping (String) -> Void ) {
//        print("func findSpreadNameAndSheets executing...")
//
//        let spreadsheetId = self.sheetID
//        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
//
//        sheetService.executeQuery(query) { (ticket, result, error) in
//            if let error = error {
//                print(error)
//                completionHandler("Error in loading sheets\n\(error.localizedDescription)")
//            } else {
//                let result = result as? GTLRSheets_Spreadsheet
//                let sheets = result?.sheets
//                if let sheetInfo = sheets {
//                    for info in sheetInfo {
//                            print("New sheet found: \(String(describing: info.properties?.title))")
//                        }
//                    }
//                completionHandler("Success!")
//            }
//        }
//    }
    
}

