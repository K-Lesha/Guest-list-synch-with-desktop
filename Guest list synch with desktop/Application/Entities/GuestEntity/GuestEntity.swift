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
    var empty: Bool
    
    //MARK: - INIT
    init() {
        self.guestName = "empty_name"
        self.guestGroup = "empty"
        self.guestsAmount = 0
        self.guestsEntered = 0
        self.giftsGifted = 0
        self.additionDate = Date().description.localizedLowercase
        self.empty = true
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
        self.empty = false
    }
}
