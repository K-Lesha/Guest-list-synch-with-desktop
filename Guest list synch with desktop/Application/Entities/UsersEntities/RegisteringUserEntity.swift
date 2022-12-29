//
//  RegisteringUser.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 08.12.2022.
//

import Foundation

struct RegisteringUser {
    var uid: String
    var name: String
    var email: String
    var signInProvider: String
    var isNew: Bool
    var surname: String?
    var userTypeRawValue: Int?
    var agency: String?
    var password: String?
}

extension RegisteringUser { 
    static func createEmptyRegisteringUser() -> RegisteringUser {
        return RegisteringUser(uid: "", name: "", email: "", signInProvider: "", isNew: true, surname: nil, userTypeRawValue: nil, agency: nil, password: nil)
    }
}
