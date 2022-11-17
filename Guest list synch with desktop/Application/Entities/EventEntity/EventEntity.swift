//
//  EventEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import Foundation

struct EventEntity {
    var eventName: String
    var eventClient: String
    var eventVenue: String
    var eventDate: String
    var eventTime: String
    var totalGuest: String
    var totalCheckedInGuests: String
    var totalGiftsGaved: String
    var eventUniqueIdentifier: String
    var initedByUserUID: String
    var initedByUserName: String
    //TODO: isOnline: Bool
    
    init() {
        eventName = "empty data"
        eventClient = "empty data"
        eventVenue = "empty data"
        eventDate = "empty data"
        eventTime = "empty data"
        totalGuest = "empty data"
        totalCheckedInGuests = "empty data"
        totalGiftsGaved = "empty data"
        eventUniqueIdentifier = "empty data"
        initedByUserUID = "empty data"
        initedByUserName = "empty data"
    }
}
