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
    func showReadGuestsError()
    func noGuestToShowAlert()
}
//MARK: View
class GuestlistViewController: UIViewController, GuestlistViewProtocol {
    
    //MARK: -VIPER protocol
    internal var presenter: GuestlistPresenterProtocol!
    
    //MARK: -OUTLETS
    private var backButton: UIButton!
    private var listAppearanceAndSettingsButton: UIButton!
    private var eventSettingsButton: UIButton!
    private var eventNameLabel: UILabel!
    private var guestSerarchBarController: UISearchController!
//    private var searchTextField: UITextField!
    private var guestListTableView: UITableView!
    private var addGuestButton: UIButton!

    
    //MARK: -viewDidLoad, -viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        print("GuestlistViewController")
        self.view.backgroundColor = .green
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.setGuestsToTheTable()
        self.presenter.updateEventEntity()

    }
    //MARK: -View methods
    func setupViews() {
        // setup@self.view
        self.navigationItem.title = "temp name"

        //setup@backButton
        backButton = UIButton()
        backButton.setTitle("⏪", for: .normal)
        backButton.backgroundColor = .black
        backButton.addTarget(self, action: #selector(backButtonPushed), for: .touchUpInside)
        let backButtomItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtomItem
        
        //setup@listAppearanceAndSettingsButton
        listAppearanceAndSettingsButton = UIButton()
        listAppearanceAndSettingsButton.setTitle("🎛", for: .normal)
        listAppearanceAndSettingsButton.backgroundColor = .black
        listAppearanceAndSettingsButton.addTarget(self, action: #selector(listAppearanceButtonPushed), for: .touchUpInside)
        let listAppearanceButtomItem = UIBarButtonItem(customView: listAppearanceAndSettingsButton)
        self.navigationItem.rightBarButtonItems = [listAppearanceButtomItem]

        //setup@eventSettingsButton
        eventSettingsButton = UIButton()
        eventSettingsButton.setTitle("🖊", for: .normal)
        eventSettingsButton.backgroundColor = .black
        eventSettingsButton.addTarget(self, action: #selector(eventSettingsButtonPushed), for: .touchUpInside)
        let eventSettingsButtomItem = UIBarButtonItem(customView: eventSettingsButton)
        self.navigationItem.rightBarButtonItems?.append(eventSettingsButtomItem)

        
        //setup@guestSerarchBarController
//        guestSerarchBarController = UISearchController(searchResultsController: nil)
//        guestSerarchBarController.searchResultsUpdater = self
//        guestSerarchBarController.obscuresBackgroundDuringPresentation = false
//        guestSerarchBarController.searchBar.showsCancelButton = true
//        guestSerarchBarController.searchBar.barStyle = .default
//        guestSerarchBarController.searchBar.placeholder = "Найти гостя..."
//        self.tabBarController?.navigationItem.searchController = guestSerarchBarController

        
        //setup@guestListTableView
        guestListTableView = UITableView()
        self.view.addSubview(guestListTableView)
        guestListTableView.delegate = self
        guestListTableView.dataSource = self
        guestListTableView.backgroundColor = .white
        guestListTableView.register(GuestTableViewCell.self, forCellReuseIdentifier: "guest")
        //constraints@guestListTableView
        guestListTableView.translatesAutoresizingMaskIntoConstraints = false
        guestListTableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        guestListTableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        guestListTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        guestListTableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        guestListTableView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        //setup@addGuestButton
        addGuestButton = UIButton()
        self.view.addSubview(addGuestButton)
        addGuestButton.setTitle("+", for: .normal)
        addGuestButton.backgroundColor = .black
        addGuestButton.addTarget(self, action: #selector(addGuestButtonPressed), for: .touchUpInside)
        //constraints@addGuestButton
        addGuestButton.translatesAutoresizingMaskIntoConstraints = false
        addGuestButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
        addGuestButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addGuestButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addGuestButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
    }
    func reloadData() {
        DispatchQueue.main.async {
            self.guestListTableView.reloadData()
        }
    }
    func noGuestToShowAlert() {
        reloadData()
        AlertsFactory.shared.showAlert(title: "NO GUEST TO SHOW HERE",
                                  message: "add some guests",
                                  viewController: self,
                                  okAlertTitle: "OK",
                                  secondAlertTitle: nil,
                                  okCompletion: nil,
                                  canselCompletion: nil)
    }

    func showReadGuestsError() {
        print("GuestlistVC showReadGuestsError")
    }
    
    @objc func backButtonPushed() {
        presenter.popToTheEventsList()
    }
    
    @objc func listAppearanceButtonPushed() {
        print("listAppearanceButtonPushed")

    }
    @objc func eventSettingsButtonPushed() {
        presenter.showEventModifyModule()
    }
    
    @objc func addGuestButtonPressed() {
        presenter.addNewGuest()
    }
    
    //MARK: Deinit
    deinit {
        print("GuestlistViewController was deinited")
    }
}

//MARK: -UITableViewDelegate, UITableViewDataSource
extension GuestlistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.guestlistFiltred.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guest", for: indexPath) as! GuestTableViewCell
        cell.guestEntity = self.presenter.guestlistFiltred[indexPath.row]
        cell.guestNameAndSurnameLabel.text = cell.guestEntity.guestName + " " + (cell.guestEntity.guestSurname ?? " ")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.showOneGuest(guest: self.presenter.guestlistFiltred[indexPath.row])
    }
}

extension GuestlistViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
