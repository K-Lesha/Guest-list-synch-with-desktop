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
    var eventID: String
    var initedByUserUID: String
    var initedByUserName: String
    var isOnline: Bool
    var guestsEntites: [GuestEntity]?
    //MARK: TOTAL GUESTS
    var totalGuests: String {
        if isOnline {
            return totalGuestsOnline ?? "0"
        } else {
           return totalGuestsOffline ?? "0"
        }
    }
    var totalGuestsOnline: String?
    var totalGuestsOffline: String? {
        if let guestsEntites {
            return String(guestsEntites.count)
        } else {
            return "0"
        }
    }
    //MARK: TOTAL CHECKED IN GUESTS
    var totalCheckedInGuests: String {
        if isOnline {
            return totalCheckedInGuestsOnline ?? "0"
        } else {
            return totalCheckedInGuestsOffline ?? "0"
        }
    }
    var totalCheckedInGuestsOnline: String?
    var totalCheckedInGuestsOffline: String? {
        if let guestsEntites {
            let result = guestsEntites.reduce((0), { $0 + $1.guestsEntered})
            return String(result)
        } else {
            return "0"
        }
    }
    //MARK: TOTAL GIFTGIFTED
    var totalGiftsGaved: String {
        if isOnline {
            return totalGiftsGavedOnline ?? "0'"
        } else {
            return totalGiftsGavedOffline ?? "0"
        }
    }
    var totalGiftsGavedOnline: String?
    var totalGiftsGavedOffline: String? {
        if let guestsEntites {
            let result = guestsEntites.reduce((0), { $0 + $1.giftsGifted})
            return String(result)
        } else {
            return "0"
        }
    }
    
    
    //MARK: -INIT
    init() {
        eventName = "empty data"
        eventClient = "empty data"
        eventVenue = "empty data"
        eventDate = "empty data"
        eventTime = "empty data"
        eventID = "empty data"
        initedByUserUID = "empty data"
        initedByUserName = "empty data"
        isOnline = false
        guestsEntites = nil
    }
    //MARK: -METHODS
    static func createOnlineEventEntityWith(eventStringArray: [[String]], eventID: String) -> EventEntity {
        var oneEvent = EventEntity()
        for (index, eventData) in eventStringArray.enumerated() {
            switch index {
            case 0:
                oneEvent.eventName = eventData.first ?? "event without name"
            case 2:
                oneEvent.eventClient = eventData.first ?? "no client data"
            case 4:
                oneEvent.eventVenue = eventData.first ?? "no venue data"
            case 6:
                oneEvent.eventDate = eventData.first ?? "unknown event date"
            case 8:
                oneEvent.eventTime = eventData.first ?? "unknown event time"
            case 10:
                oneEvent.totalGuestsOnline = eventData.first ?? "no info"
            case 12:
                oneEvent.totalCheckedInGuestsOnline = eventData.first ?? "no info"
            case 14:
                oneEvent.totalGiftsGavedOnline = eventData.first ?? "no info"
            case 16:
                oneEvent.initedByUserUID = eventData.first ?? "no info"
            case 18:
                oneEvent.initedByUserName = eventData.first ?? "no info"
            default:
                break
            }
        }
        oneEvent.eventID = eventID
        oneEvent.isOnline = true
        oneEvent.guestsEntites = nil
        return oneEvent
    }
    
    static func createDemoOfflineEvent(userUID: String,
                                       userName: String) -> EventEntity {
        var offlineDemoEntity = EventEntity()
        offlineDemoEntity.eventName = "Demo event"
        offlineDemoEntity.eventClient = "Demo client"
        offlineDemoEntity.eventVenue = "Demo venue"
        offlineDemoEntity.eventDate = Date().formatted(date: .abbreviated, time: .omitted)
        offlineDemoEntity.eventTime = Date().formatted(date: .omitted, time: .shortened)
        offlineDemoEntity.eventID = UUID().uuidString
        offlineDemoEntity.initedByUserUID = userUID
        offlineDemoEntity.initedByUserName = userName
        offlineDemoEntity.guestsEntites = GuestEntity.createGuestsArrayForDemo()
        offlineDemoEntity.isOnline = false
        return offlineDemoEntity
    }
    static func createEmptyOfflineEvent(eventName: String,
                                        eventClient: String?,
                                        eventVenue: String?,
                                        eventDate: String,
                                        eventTime: String,
                                        userUID: String,
                                        userName: String) -> EventEntity {
        var emptyOfflineEventEntity = EventEntity()
        emptyOfflineEventEntity.eventName = eventName
        emptyOfflineEventEntity.eventClient = eventClient ?? " "
        emptyOfflineEventEntity.eventVenue = eventVenue ?? " "
        emptyOfflineEventEntity.eventDate = eventDate
        emptyOfflineEventEntity.eventTime = eventTime
        emptyOfflineEventEntity.eventID = UUID().uuidString
        emptyOfflineEventEntity.initedByUserUID = userUID
        emptyOfflineEventEntity.initedByUserName = userName
        emptyOfflineEventEntity.guestsEntites = [GuestEntity]()
        emptyOfflineEventEntity.isOnline = false
        return emptyOfflineEventEntity
    }
}
