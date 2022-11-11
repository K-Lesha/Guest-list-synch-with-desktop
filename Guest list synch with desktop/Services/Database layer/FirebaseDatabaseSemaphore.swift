//
//  FirebaseDatabaseSemaphore.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 11.11.2022.
//

import Foundation

//MARK: Dispatch semaphore
class FirebaseDatabaseSemaphore {
    static let shared = DispatchSemaphore(value: 0)
    private init() {}
}
