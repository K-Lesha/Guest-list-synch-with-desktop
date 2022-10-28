//
//  EventEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 25.10.2022.
//

import Foundation

struct EventEntity {
    var eventName: String
    var eventClient: String?
    var eventVenue: String?
    var eventDate: String?
    var eventTime: String?
    var freshEvent: Bool {
        return true
    }
    var eventUniqueIdentifier: String
    var initedByUserUID: String?
    var initedByUserName: String?
}
