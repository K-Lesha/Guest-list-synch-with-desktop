//
//  EventEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import Foundation

struct EventEntity {
    var eventName: String
    var eventDate: String?
    var eventTime: String?
    var eventVenue: String?
    var eventColor: String?
    var eventLogoURLString: String?
    var freshEvent: Bool?
    var eventGuests: [GuestEntity]?
    
    init(eventName: String) {
        self.eventName = eventName
    }
}
