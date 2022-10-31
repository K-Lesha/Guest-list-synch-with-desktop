//
//  EventsListSemaphore.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation

//MARK: Dispatch semaphore
class EventsListSemaphore {
    static let shared = DispatchSemaphore(value: 0)
    private init() {}
}
