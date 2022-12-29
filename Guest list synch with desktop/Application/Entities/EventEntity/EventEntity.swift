//
//  EventEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import Foundation

struct EventEntity {
    var name: String
    var client: String
    var venue: String
    var date: String
    var time: String
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
    
}

extension EventEntity {
    //MARK: -INIT
    init() {
        name = "empty data"
        client = "empty data"
        venue = "empty data"
        date = "empty data"
        time = "empty data"
        eventID = "empty data"
        initedByUserUID = "empty data"
        initedByUserName = "empty data"
        isOnline = false
        guestsEntites = nil
    }
    //MARK: -ONLINE EVENT METHODS
    static func createOnlineEventEntityWith(eventStringArray: [[String]], eventID: String) -> EventEntity {
        var oneEvent = EventEntity()
        for (index, eventData) in eventStringArray.enumerated() {
            switch index {
            case 0:
                oneEvent.name = eventData.first ?? "event without name"
            case 2:
                oneEvent.client = eventData.first ?? "no client data"
            case 4:
                oneEvent.venue = eventData.first ?? "no venue data"
            case 6:
                oneEvent.date = eventData.first ?? "unknown event date"
            case 8:
                oneEvent.time = eventData.first ?? "unknown event time"
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
    
    //MARK: OFFLINE EVENT METHODS
    static func createDemoOfflineEvent(userUID: String,
                                       userName: String) -> EventEntity {
        var offlineDemoEntity = EventEntity()
        offlineDemoEntity.name = "Demo event"
        offlineDemoEntity.client = "Demo client"
        offlineDemoEntity.venue = "Demo venue"
        offlineDemoEntity.date = Date().formatted(date: .abbreviated, time: .omitted)
        offlineDemoEntity.time = Date().formatted(date: .omitted, time: .shortened)
        offlineDemoEntity.eventID = UUID().uuidString
        offlineDemoEntity.initedByUserUID = userUID
        offlineDemoEntity.initedByUserName = userName
        offlineDemoEntity.guestsEntites = GuestEntity.createGuestsArrayForDemoEvent()
        offlineDemoEntity.isOnline = false
        return offlineDemoEntity
    }
    static func createEmptyOfflineEvent(eventName: String,
                                        eventClient: String?,
                                        eventVenue: String?,
                                        eventDate: String,
                                        eventTime: String?,
                                        userUID: String,
                                        userName: String) -> EventEntity {
        var emptyOfflineEventEntity = EventEntity()
        emptyOfflineEventEntity.name = eventName
        emptyOfflineEventEntity.client = eventClient ?? " "
        emptyOfflineEventEntity.venue = eventVenue ?? " "
        emptyOfflineEventEntity.date = eventDate
        emptyOfflineEventEntity.time = eventTime ?? " "
        emptyOfflineEventEntity.eventID = UUID().uuidString
        emptyOfflineEventEntity.initedByUserUID = userUID
        emptyOfflineEventEntity.initedByUserName = userName
        emptyOfflineEventEntity.guestsEntites = [GuestEntity]()
        emptyOfflineEventEntity.isOnline = false
        return emptyOfflineEventEntity
    }
    static func createEventsArrayFrom(_ nsDictionary: NSDictionary) -> [EventEntity] {
        var eventsArray = [EventEntity]()
        
        let eventsDictionary = nsDictionary as! Dictionary<String, NSDictionary>
        
        for (_, value) in eventsDictionary {
            let eventEntity = createOneOfflineEventFrom(value)
            eventsArray.append(eventEntity)
        }
        return eventsArray
    }
    static func createOneOfflineEventFrom(_ dictionary: NSDictionary) -> EventEntity {
        var eventEntity = EventEntity()
        eventEntity.name = dictionary.object(forKey: "name") as! String
        eventEntity.client = dictionary.object(forKey: "client") as? String ?? "no data about client"
        eventEntity.date = dictionary.object(forKey: "date") as! String
        eventEntity.eventID = dictionary.object(forKey: "eventID") as! String
        eventEntity.time = dictionary.object(forKey: "time") as? String ?? "no info about time"
        eventEntity.venue = dictionary.object(forKey: "venue") as? String ?? "no venue data"
        eventEntity.initedByUserUID = dictionary.object(forKey: "initedByUserUID") as! String
        eventEntity.initedByUserName = dictionary.object(forKey: "initedByUserName") as! String
        eventEntity.isOnline = dictionary.object(forKey: "isOnline") as! Bool
        let dictGuestlist = dictionary.object(forKey: "guestEntities") as? NSDictionary
        let guestlist = GuestEntity.createGuestsArrayFrom(dictGuestlist)
        eventEntity.guestsEntites = guestlist
        return eventEntity
    }
}
