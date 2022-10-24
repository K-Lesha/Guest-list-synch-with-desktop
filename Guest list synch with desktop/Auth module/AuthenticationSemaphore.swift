//
//  AuthenticationSemaphore.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

//MARK: Dispatch semaphore
class AuthenticationSemaphore {
    static let shared = DispatchSemaphore(value: 0)
    private init() {}
}
