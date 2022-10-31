//
//  EventsListViewController.swift
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
    
    //MARK: -VIPER protocol
    internal var presenter: EventsListPresenterProtocol!
    
    //MARK: -View properties
    var eventsList = [EventEntity]()
    
    //MARK: -OUTLETS
    internal var currentEventsButton: UIButton!
    internal var pastEventsButton: UIButton!
    internal var profileButton: UIButton!
    internal var eventsTableView: UITableView!
    internal var addEventButton: UIButton!
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: -METHODS
    //MARK: View methods
    private func setupViews() {
        //setup@self.view
        self.view.backgroundColor = .white
        
        //setup@currentEventsButton
        currentEventsButton = UIButton()
        currentEventsButton.setTitle("Current", for: .normal)
        currentEventsButton.backgroundColor = .black
        currentEventsButton.addTarget(self, action: #selector(currentEventsButtonPressed), for: .touchUpInside)
        let currentEventsBarButtomItem = UIBarButtonItem(customView: currentEventsButton)
        self.navigationItem.leftBarButtonItems = [currentEventsBarButtomItem]
//        self.navigationController?.navigationItem.leftBarButtonItem = currentEventsBarButtomItem
        //constraints@currentEventsButton
        currentEventsButton.translatesAutoresizingMaskIntoConstraints = false
//        currentEventsButton.leftAnchor.constraint(equalTo: self.navigationController!.view.leftAnchor, constant: 20).isActive = true
//        currentEventsButton.topAnchor.constraint(equalTo: self.navigationController!.view.topAnchor, constant: 50).isActive = true
//        currentEventsButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
//        currentEventsButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //setup@pastEventsButton
        pastEventsButton = UIButton()
        pastEventsButton.setTitle("Past", for: .normal)
        pastEventsButton.backgroundColor = .black
        pastEventsButton.addTarget(self, action: #selector(pastEventsButtonPressed), for: .touchUpInside)
        let pastEventsButtonBarButtomItem = UIBarButtonItem(customView: pastEventsButton)
        self.navigationItem.leftBarButtonItems?.append(pastEventsButtonBarButtomItem)
        //constraints@pastEventsButton
//        pastEventsButton.translatesAutoresizingMaskIntoConstraints = false
//        pastEventsButton.leftAnchor.constraint(equalTo: currentEventsButton.rightAnchor, constant: 7).isActive = true
//        pastEventsButton.topAnchor.constraint(equalTo: currentEventsButton.topAnchor).isActive = true
//        pastEventsButton.widthAnchor.constraint(equalTo: currentEventsButton.widthAnchor).isActive = true
//        pastEventsButton.heightAnchor.constraint(equalTo: currentEventsButton.heightAnchor).isActive = true

        
        //setup@profileButton
        profileButton = UIButton()
        profileButton.setTitle("👧", for: .normal)
        profileButton.backgroundColor = .black
        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        let profileButtonBarButtomItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.rightBarButtonItem = profileButtonBarButtomItem
        //constraints@profileButton
//        profileButton.translatesAutoresizingMaskIntoConstraints = false
//        profileButton.rightAnchor.constraint(equalTo: self.navigationController!.view.rightAnchor, constant: -20).isActive = true
//        profileButton.topAnchor.constraint(equalTo: currentEventsButton.topAnchor).isActive = true
//        profileButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
//        profileButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //setup@eventsTableView
        eventsTableView = UITableView()
        self.view.addSubview(eventsTableView)
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.backgroundColor = .gray
        eventsTableView.register(EventTableViewCell.self, forCellReuseIdentifier: "event")
        //constraints@eventsTableView
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        eventsTableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        eventsTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        eventsTableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        eventsTableView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        // download events and set them to view
        setOneEventToTableView()
        
        //setup@sheetsButton
        addEventButton = UIButton()
        self.view.addSubview(addEventButton)
        addEventButton.setTitle("+", for: .normal)
        addEventButton.backgroundColor = .black
        addEventButton.addTarget(self, action: #selector(addEventButtonPressed), for: .touchUpInside)
        //constraints@sheetsButton
        addEventButton.translatesAutoresizingMaskIntoConstraints = false
        addEventButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        addEventButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addEventButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addEventButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
    }
    func setOneEventToTableView() {
        self.presenter.setDataToTheView { result in
            switch result {
            case .success(let oneEventInArray):
                self.eventsList = oneEventInArray
                self.eventsTableView.reloadData()
            case .failure(let error):
                print (error.localizedDescription)
            }
        }
        //        print("appendData")
        //        appendData { (string) in
        //            self.utils.showAlert(title: "", message: string, vc: self)
        //        }
        
        //                print("readSheets")
        //        readSheets { (string) in
        //            self.utils.showAlert(title: "", message: string, vc: self)
        //        }
        
        //        print("sendDataToCell")
        //        sendDataToCell { (string) in
        //            self.utils.showAlert(title: "", message: string, vc: self)
        //        }
    }
    
    //MARK: Button methods
    @objc func addEventButtonPressed() {
        
    }
    
    @objc func currentEventsButtonPressed() {
        
    }
    
    @objc func pastEventsButtonPressed() {
        
    }
    @objc func profileButtonPressed() {
        self.presenter.showProfile()
    }

    //MARK: Deinit
    deinit {
        print("EventsListViewController was deinited")
    }
}

extension EventsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventTableViewCell
        cell.eventNameLabel.text = self.eventsList[indexPath.row].eventName
        cell.venueLabel.text = self.eventsList[indexPath.row].eventVenue
        cell.eventDateAndTimeLabel.text = "\(self.eventsList[indexPath.row].eventDate ?? ""), \(self.eventsList[indexPath.row].eventTime ?? "")"
        cell.guestsAmountLabel.text = "57"
        return cell
    }
}
