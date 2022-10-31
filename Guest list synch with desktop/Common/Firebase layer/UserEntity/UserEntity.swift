//
//  UserEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 28.10.2022.
//

import Foundation


enum UserTypes: Int {
    case demoUser = 0 // temporary status, before he created an event
    case headOrganizer = 1 // can create events, and manage them, can create guestlist and manage them
    case coorganizer = 2 // can create own events and can see headOrganizer events
    case hostess = 3 // can see events by headOrganizer and coOrganizer, cant create own events
    case client = 4 // can see events by organizer and coOrganizer, cant create own events
}

struct UserEntity {
    var uid: String
    var payedEvents: Int
    var eventsIdList: [String]
    var delegatedEventIdList: [String]?
    var accessLevel: UserTypes
    var coorganizers: [SupportingUserEntity]?
    var headOrganizers: [SupportingUserEntity]?
    var hostesses: [SupportingUserEntity]?
    var name: String
    var surname: String?
    var email: String
    var active: Bool
    var agency: String?
    var avatarLinkString: String?
    var registrationDate: String
    var signInProvider: String
}
