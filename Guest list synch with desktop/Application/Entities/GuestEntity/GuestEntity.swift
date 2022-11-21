//
//  GuestEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import Foundation

struct GuestEntity {
    //MARK: PROPERTIES
    var guestName: String
    var guestSurname: String?
    var companyName: String?
    var positionInCompany: String?
    var guestGroup: String?
    var guestsAmount: Int
    var guestsEntered: Int
    var giftsGifted: Int
    var photoURL: String?
    var phoneNumber: String?
    var guestEmail: String?
    var internalNotes: String?
    var additionDate: String
    
    var guestRowInSpreadSheet: String?
    var empty: Bool {
        if guestName == "" || guestName == "empty_name" || guestName == " "  {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - INIT
    init() {
        self.guestName = "empty_name"
        self.guestGroup = "empty"
        self.guestsAmount = 0
        self.guestsEntered = 0
        self.giftsGifted = 0
        self.additionDate = Date().description.localizedLowercase
    }
    init(guestName: String,
         guestSurname: String?,
         companyName: String?,
         positionInCompany: String?,
         guestGroup: String?,
         guestsAmount: Int,
         photoURL: String?,
         phoneNumber: String?,
         guestEmail: String?,
         internalNotes: String?,
         guestRowInSpreadSheet: Int?) {
        self.guestName = guestName
        self.guestSurname = guestSurname
        self.companyName = companyName
        self.positionInCompany = positionInCompany
        self.guestGroup = guestGroup
        self.guestsAmount = guestsAmount
        self.guestsEntered = 0
        self.giftsGifted = 0
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.guestEmail = guestEmail
        self.internalNotes = internalNotes
        self.additionDate = Date().description.localizedLowercase
        if let guestRowInSpreadSheet {
            self.guestRowInSpreadSheet = String(guestRowInSpreadSheet)
        } else {
            self.guestRowInSpreadSheet = nil
        }
    }
    
    static func createGuestEntityWith(guestStringArray: [String], row: Int) -> GuestEntity {
        var oneGuest = GuestEntity()
        for (index, guestData) in guestStringArray.enumerated() {
            switch index {
            case 0:
                oneGuest.guestName = guestData
            case 1:
                oneGuest.guestSurname = guestData
            case 2:
                oneGuest.companyName = guestData
            case 3:
                oneGuest.positionInCompany = guestData
            case 4:
                oneGuest.guestGroup = guestData
            case 5:
                oneGuest.guestsAmount = Int(guestData)!
            case 6:
                oneGuest.guestsEntered = Int(guestData)!
            case 7:
                oneGuest.giftsGifted = Int(guestData)!
            case 8:
                oneGuest.photoURL = guestData
            case 9:
                oneGuest.phoneNumber = guestData
            case 10:
                oneGuest.guestEmail = guestData
            case 11:
                oneGuest.internalNotes = guestData
            case 12:
                oneGuest.additionDate = guestData
            default:
                break
            }
            oneGuest.guestRowInSpreadSheet = String(row)
        }
        return oneGuest
    }
    
         
    static func createGuestsArrayForDemo() -> [GuestEntity] {
        var tempGuestsArray = [GuestEntity]()
        //Data for demo guests
        let randomNames = ["John", "George", "Nathaly", "Megan", "Tom", "Jeniffer", "Leo"]
        let randomSurnames = ["Low", "Fines", nil, "Krayg", nil, "Pattison", "Lory"]
        let randomCompanyNames = ["Paramount", nil, "Essanay Studios", "Joy Entertainment", "Cube Records", nil, "Starship"]
        let randomPositions = ["Scientist", "Engineer", nil, "Developer", nil, "Assistant", "Analysts"]
        let randomGroup = ["VIP", "Group 1", "VIP", "Group 1", "Group 2", "VIP", "Group 3"]
        let randomPhotoURLs = ["https://images.unsplash.com/photo-1618077360395-f3068be8e001?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8bWFuJTIwZmFjZXxlbnwwfDJ8MHx8&auto=format&fit=crop&w=900&q=60",
                               nil,
                               "https://assets.website-files.com/5d769a7fb9339d831b254d41/5d7754325b3233a81e865b4c_IMAGE%202019-09-09%2022_05_32.jpg",
                               nil,
                               "https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8bWFuJTIwZmFjZXxlbnwwfDJ8MHx8&auto=format&fit=crop&w=900&q=60",
                               nil,
                               "https://images.unsplash.com/photo-1509399693673-755307bfc4e1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjJ8fG1hbiUyMGZhY2V8ZW58MHwyfDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60"]
        let randomPhoneNumbers =  ["+0(123)456-78-90", nil, "+0(123)456-78-90", "+0(123)456-78-90", nil, "+0(123)456-78-90", nil]
        let randomEmails = ["abcdef@ghigk.lmn", "abcdef@ghigk.lmn", nil, "abcdef@ghigk.lmn", "abcdef@ghigk.lmn", nil, "abcdef@ghigk.lmn"]
        let randomInternalNotes = Array<String>.init(repeating: "Here you can add some notes", count: 7)
        // Appending random guests to temp array
        for index in 0..<randomNames.count {
            let randomGuest = GuestEntity(guestName: randomNames[index],
                                          guestSurname: randomSurnames[index],
                                          companyName: randomCompanyNames[index],
                                          positionInCompany: randomPositions[index],
                                          guestGroup: randomGroup[index],
                                          guestsAmount: Int.random(in: 1...3),
                                          photoURL: randomPhotoURLs[index],
                                          phoneNumber: randomPhoneNumbers[index],
                                          guestEmail: randomEmails[index],
                                          internalNotes: randomInternalNotes[index],
                                          guestRowInSpreadSheet: nil)
            tempGuestsArray.append(randomGuest)
        }
        //Return temp array
        return tempGuestsArray
    }
    static func createGuestsArrayFromDict() -> [GuestEntity] {
        
        return [GuestEntity()]
    }
    static func createGuestsDictFromArray(_ guestsArray: [GuestEntity]?) -> [NSDictionary] {
        if let guestsArray {
            var guestsDictionary = [[String : Any]]()
            
            for guest in guestsArray {
                let guestDictionary = [
                    "guestName": guest.guestName,
                    "guestSurname": guest.guestSurname ?? " ",
                    "companyName": guest.companyName ?? " ",
                    "positionInCompany": guest.positionInCompany ?? " ",
                    "guestGroup": guest.guestGroup ?? " ",
                    "guestsAmount": String(guest.guestsAmount),
                    "guestsEntered": String(guest.guestsEntered),
                    "giftsGifted": String(guest.giftsGifted),
                    "photoURL": guest.photoURL ?? " ",
                    "phoneNumber": guest.phoneNumber ?? " ",
                    "guestEmail": guest.guestEmail ?? " ",
                    "internalNotes": guest.internalNotes ?? " ",
                    "additionDate": guest.additionDate
                ] as [String : Any]
                guestsDictionary.append(guestDictionary)
            }
            
            return guestsDictionary as [NSDictionary]
        } else {
            return [NSDictionary()]
        }
    }
    
    static func createOneGuestFrom(_ nsDictionary: NSDictionary) -> GuestEntity {
        var guest = GuestEntity()
        guest.guestName = nsDictionary.object(forKey: "guestName") as! String
        guest.guestSurname = nsDictionary.object(forKey: "guestSurname") as? String
        guest.companyName = nsDictionary.object(forKey: "companyName") as? String
        guest.positionInCompany = nsDictionary.object(forKey: "positionInCompany") as? String
        guest.guestGroup = nsDictionary.object(forKey: "guestGroup") as? String
        guest.guestsAmount = Int(nsDictionary.object(forKey: "guestsAmount") as? String ?? "0")!
        guest.guestsEntered = Int(nsDictionary.object(forKey: "guestsEntered") as? String ?? "0")!
        guest.giftsGifted = Int(nsDictionary.object(forKey: "giftsGifted") as? String ?? "0")!
        guest.photoURL = nsDictionary.object(forKey: "photoURL") as? String
        guest.phoneNumber = nsDictionary.object(forKey: "phoneNumber") as? String
        guest.guestEmail = nsDictionary.object(forKey: "guestEmail") as? String
        guest.internalNotes = nsDictionary.object(forKey: "internalNotes") as? String
        guest.additionDate = nsDictionary.object(forKey: "additionDate") as! String
        return guest
    }
}
