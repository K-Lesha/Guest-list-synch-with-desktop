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
    
    var guestGroup: Int
    
    var guestsAmount: Int
    var guestsEntered: Int
    var giftsGifted: Int
    var photoURL: String?
    var phoneNumber: String?
    var guestEmail: String?
    var internalNotes: String?
    var additionDate: String
    
    //MARK: - INIT
    init() {
        self.guestName = "empty_name"
        self.guestGroup = 0
        self.guestsAmount = 0
        self.guestsEntered = 0
        self.giftsGifted = 0
        self.additionDate = Date().description.localizedLowercase
    }
    init(guestName: String,
         guestSurname: String?,
         companyName: String?,
         positionInCompany: String?,
         guestGroup: Int,
         guestsAmount: Int,
         photoURL: String?,
         phoneNumber: String?,
         guestEmail: String?,
         internalNotes: String?) {
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
    }
}
