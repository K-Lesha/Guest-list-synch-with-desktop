//
//  LoggedInInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import Foundation

protocol EventsListInteractorProtocol {
    //VIPER protocol
    var networkService: NetworkServiceProtocol! {get set}
    init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol)
    //Firebase methods
    
}

class EventsListInteractor: EventsListInteractorProtocol {
    
    //MARK: VIPER protocol
    internal var networkService: NetworkServiceProtocol!
    internal required init (networkService: NetworkServiceProtocol, firebaseService: FirebaseServiceProtocol) {
        self.networkService = networkService
    }
    //MARK: Firebase methods
    

}
