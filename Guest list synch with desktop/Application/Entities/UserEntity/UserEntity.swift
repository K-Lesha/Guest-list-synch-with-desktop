//
//  UserEntity.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 28.10.2022.
//

import Foundation


enum UserTypes: Int {
    case organizer = 0 // can create events and manage them, can create guestlists and manage them, can see other organizer events
    case hostess = 1 // can see events by organizer, cant create own events, can manage guestlist
    case client = 2 // can see events by organizer, cant create own events, can manage guestlist
    
    static var count: Int {
        return UserTypes.client.rawValue + 1
    }
    var description: String {
        switch self {
        case .organizer: return "Организатор или со-организатор"
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
