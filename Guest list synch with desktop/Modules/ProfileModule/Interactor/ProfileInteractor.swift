//
//  ProfileInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation

protocol ProfileInteractorProtocol {
    //VIPER protocol
    var firebaseDatabase: FirebaseDatabaseProtocol! {get set}
    var firebaseService: FirebaseServiceProtocol! {get set}
    init (firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol)
    //Spreadsheet methods
    func logOut()

    
}

class ProfileInteractor: ProfileInteractorProtocol {
    
    var firebaseDatabase: FirebaseDatabaseProtocol!
    var firebaseService: FirebaseServiceProtocol!
    
    required init(firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.firebaseService = firebaseService
        self.firebaseDatabase = firebaseDatabase
    }
    
    func logOut() {
        firebaseService.logOutWithFirebase()
    }
    
    
}
