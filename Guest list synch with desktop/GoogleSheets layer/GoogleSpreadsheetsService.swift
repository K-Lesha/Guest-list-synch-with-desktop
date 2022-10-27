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
    
    
}

enum SheetsRange: String {
    case oneEventData = "A1:B14"
    case guestsData = "A16:N"
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
    var sheetID = "1OlZ7J45qI3zE9ViWcpgc5ZCmhPWdpgh8rlABjTy3dWk"

    
    //MARK: Spreadsheets methods
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
    func readData(range: SheetsRange, completionHandler: @escaping (String) -> Void) {
        print("Getting sheet data...")
    
        let spreadsheetId = self.sheetID
        let range = range.rawValue
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Failed to read data:\(error.localizedDescription)")
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                return
            }
            
            let rows = result.values!
            var stringRows = rows as! [[String]]
            
            for row in stringRows {
                stringRows.append(row)
                print(row)
                }
            if rows.isEmpty {
                print("No data found.")
                return
            }
            completionHandler("Success!")
            print("Number of rows in sheet: \(rows.count)")
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

