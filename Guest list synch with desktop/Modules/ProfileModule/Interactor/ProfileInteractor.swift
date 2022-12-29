//
//  ProfileInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import Foundation

protocol ProfileInteractorProtocol {
    //Init
    init (firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol)
    //Spreadsheet methods
    func logOut()

    
}

class ProfileInteractor: ProfileInteractorProtocol {
    //MARK: Properties
    private var firebaseDatabase: FirebaseDatabaseProtocol!
    private var firebaseService: FirebaseServiceProtocol!
    //MARK: INIT
    required init(firebaseService: FirebaseServiceProtocol, firebaseDatabase: FirebaseDatabaseProtocol) {
        self.firebaseService = firebaseService
        self.firebaseDatabase = firebaseDatabase
    }
    //MARK: Methods
    func logOut() {
        firebaseService.signOut() {_ in
            
        }
    }
    
    
}
