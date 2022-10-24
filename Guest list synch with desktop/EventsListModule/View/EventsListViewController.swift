//
//  LoggedInViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import UIKit

// MARK: Protocol
protocol EventsListViewControllerProtocol: AnyObject {
    //VIPER protocol
    var presenter: EventsListPresenterProtocol! {get set}
    //Methods
}
//MARK: View
class EventsListViewController: UIViewController, EventsListViewControllerProtocol {
    
    //MARK: VIPER protocol
    internal var presenter: EventsListPresenterProtocol!
    
    //MARK: OUTLETS
        
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseService().checkUserLoginnedWithFacebook()
        setupViews()
    }
    //MARK: METHODS
    //MARK: View methods
    private func setupViews() {
        //setup@deleteAccountButton
       
        //setup@logoutButton
       
        
    }
    

    //MARK: Button methods
    
    
    //MARK: Deinit
    deinit {
        print("EventsListViewController was deinited")
    }
}

