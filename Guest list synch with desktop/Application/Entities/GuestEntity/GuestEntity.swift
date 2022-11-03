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
    var guestSurname: String
    
    //MARK: - INIT
    init() {
        guestName = "empty_name"
        guestSurname = "empty_surname"
    }
    init(guestName: String, guestSurname: String) {
        self.guestName = guestName
        self.guestSurname = guestSurname
    }
}
