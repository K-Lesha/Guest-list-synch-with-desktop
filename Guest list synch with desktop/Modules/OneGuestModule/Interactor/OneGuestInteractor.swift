//
//  OneGuestInteractor.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 14.11.2022.
//

import Foundation

protocol OneGuestInteractorProtocol {
    // VIPER PROTOCOL
    var networkService: NetworkServiceProtocol! {get set}
    // Init
    init(networkService: NetworkServiceProtocol)
    // Methods
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

class OneGuestInteractor: OneGuestInteractorProtocol {
    //MARK: -VIPER PROTOCOL
    var networkService: NetworkServiceProtocol!
    
    //MARK: -INIT
    required init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    //MARK: -METHODS
    func setGuestPhoto(stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        networkService.downloadImage(urlString: stringURL, completionBlock: completion)
    }
    
}
