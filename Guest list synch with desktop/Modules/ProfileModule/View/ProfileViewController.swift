//
//  ProfileViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 31.10.2022.
//

import UIKit

protocol ProfileViewControllerProtocol {
    //VIPER protocol
    var presenter: ProfilePresenterProtocol! {get set}
    //Methods
}

class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    //MARK: -VIPER protocol
    var presenter: ProfilePresenterProtocol!

    
    
    //MARK: - OUTLETS
    internal var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        
        //setup@logOutButton
        logOutButton = UIButton()
        logOutButton.setTitle("Log out", for: .normal)
        logOutButton.titleLabel?.font = Appearance.buttomsFont
        logOutButton.backgroundColor = .black
        logOutButton.setTitleColor(.white, for: .normal)
        logOutButton.addTarget(self, action: #selector(logOutButtonPressed), for: .touchUpInside)
        let  logOutBarButtomItem = UIBarButtonItem(customView: logOutButton)
        self.navigationItem.rightBarButtonItem = logOutBarButtomItem
        
    }
    
    @objc func logOutButtonPressed() {
        presenter.logOut()
    }

    //MARK: Deinit
    deinit {
        print("ProfileViewController was deinited")
    }
}
