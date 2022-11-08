//
//  UserEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 28.10.2022.
//

import Foundation


enum UserTypes: Int {
    case headOrganizer = 0 // can create events, and manage them, can create guestlist and manage them
    case coorganizer = 1 // can create own events and can see headOrganizer events
    case hostess = 2 // can see events by headOrganizer and coOrganizer, cant create own events
    case client = 3 // can see events by organizer and coOrganizer, cant create own events
    case empty = 4
    
    static var count: Int {
        return UserTypes.empty.rawValue + 1
    }
    var description: String {
        switch self {
        case .empty: return ""
        case .headOrganizer: return "Организатор"
        case .coorganizer: return "Со-организатор"
        case .hostess: return "Хостесс"
        case .client: return "Клиент"
        }
    }
    
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
