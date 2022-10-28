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
    
    func readOneEventData(range: SheetsRange, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void)
}

enum SheetsRange: String {
    case oneEventData = "A1:A16"
    case guestsData = "A19:N"
}
enum SheetsError: Error {
    case error
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
    static let grantedScopes = "https://www.googleapis.com/auth/spreadsheets"
    static let additionalScopes = ["https://www.googleapis.com/auth/spreadsheets",
                            "https://www.googleapis.com/auth/drive.file"]
    var sheetID = "nil"

    
    //MARK: Spreadsheets methods
    func readOneEventData(range: SheetsRange, completionHandler: @escaping (Result<[[String]], SheetsError>) -> Void) {
        print("Getting sheet data...")
        sheetID = FirebaseService.logginnedUser!.eventsIdList[0]
        let spreadsheetId = self.sheetID
        let range = range.rawValue
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error {
                completionHandler(.failure(.error))
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                completionHandler(.failure(.error))
                return
            }
            
            var stringRows = result.values! as! [[String]]
            
            if stringRows.isEmpty {
                completionHandler(.failure(.error))
                return
            }
            completionHandler(.success(stringRows))
        }
    }
    
    
    
    
    
    
    
    func appendData(completionHandler: @escaping (String) -> Void) {

        let spreadsheetId = self.sheetID
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        let data = ["this", "is","a","test"]
        
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        
            sheetService.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in appending data: \(error)")
                    completionHandler("Error in sending data:\n\(error.localizedDescription)")
                } else {
                    print("Data sent: \(data)")
                    completionHandler("Success!")
                }
            }
        }

    func sendDataToCell(completionHandler: @escaping (String) -> Void) {
            
            let spreadsheetId = self.sheetID
            let currentRange = "A5:B5" //Any range on the sheet, for instance: A5:B6
            let results = ["this is a test"]
            let rangeToAppend = GTLRSheets_ValueRange.init();
                rangeToAppend.values = [results]
        
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: currentRange)
                query.valueInputOption = "USER_ENTERED"
        
                sheetService.executeQuery(query) { (ticket, result, error) in
                    if let error = error {
                        print(error)
                        completionHandler("Error in sending data:\n\(error.localizedDescription)")
                    } else {
                        print("Sending: \(results)")
                        completionHandler("Sucess!")
                    }
                }
    }


    func readSheets(completionHandler: @escaping (String) -> Void ) {
        print("func findSpreadNameAndSheets executing...")
        
        let spreadsheetId = self.sheetID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Error in loading sheets\n\(error.localizedDescription)")
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let sheets = result?.sheets
                if let sheetInfo = sheets {
                    for info in sheetInfo {
                            print("New sheet found: \(String(describing: info.properties?.title))")
                        }
                    }
                completionHandler("Success!")
            }
        }
    }
    
}

