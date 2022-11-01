//
//  GuestlistViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 01.11.2022.
//

import UIKit
// MARK: Protocol
protocol GuestlistViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: GuestlistPresenterProtocol! {get set}
    //Methods
    func reloadData()
    func showError()
}
//MARK: View
class GuestlistViewController: UIViewController, GuestlistViewProtocol {
    
    //MARK: -VIPER protocol
    internal var presenter: GuestlistPresenterProtocol!
    
    //MARK: -OUTLETS
    private var backButton: UIButton!
//    private var listAppearance: UIButton!
//    private var searchTextField: UITextField!
//    private var guestListTableView: UITableView!
//    private var addGuestButton: UIButton!
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    //MARK: -View methods
    func setupViews() {
        //setup@backButton
        backButton = UIButton()
        backButton.setTitle("<", for: .normal)
        backButton.backgroundColor = .black
        backButton.addTarget(self, action: #selector(backButtonPushed), for: .touchUpInside)
        let backButtomItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [backButtomItem]
        
        
        
    }
    func reloadData() {
//        guestListTableView.reloadData()
    }
    func showError() {
        
    }
    
    @objc func backButtonPushed() {
        presenter.popToTheEventsList()
    }



}
