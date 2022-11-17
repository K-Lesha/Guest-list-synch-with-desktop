//
//  AddModifyEventSemaphore.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 17.11.2022.
//

import Foundation

//MARK: Dispatch semaphore
class AddModifyEventSemaphore {
    static let shared = DispatchSemaphore(value: 0)
    private init() {}
}
