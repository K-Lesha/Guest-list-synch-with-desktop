//
//  EventsListSemaphore.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 21.11.2022.
//

import Foundation

//MARK: Dispatch semaphore
class EventsListSemaphore {
    static let shared = DispatchSemaphore(value: 0)
    private init() {}
}
