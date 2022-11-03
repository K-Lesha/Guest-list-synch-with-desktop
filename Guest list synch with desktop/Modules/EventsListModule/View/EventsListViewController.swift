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
    func reloadData()
    func showError()
}
//MARK: View
class EventsListViewController: UIViewController, EventsListViewControllerProtocol {
    
    //MARK: -VIPER protocol
    internal var presenter: EventsListPresenterProtocol!
    
    //MARK: -OUTLETS
    private var allEventsButton: UIButton!
    private var currentEventsButton: UIButton!
    private var pastEventsButton: UIButton!
    private var profileButton: UIButton!
    private var eventsTableView: UITableView!
    private var addEventButton: UIButton!
    
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
        
        //setup@allEventsButton
        allEventsButton = UIButton()
        allEventsButton.setTitle("All events", for: .normal)
        allEventsButton.backgroundColor = .black
        allEventsButton.addTarget(self, action: #selector(allEventsButtonPressed), for: .touchUpInside)
        let allEventsBarButtomItem = UIBarButtonItem(customView: allEventsButton)
        self.navigationItem.leftBarButtonItems = [allEventsBarButtomItem]
        
        //setup@currentEventsButton
        currentEventsButton = UIButton()
        currentEventsButton.setTitle("Current", for: .normal)
        currentEventsButton.backgroundColor = .black
        currentEventsButton.addTarget(self, action: #selector(currentEventsButtonPressed), for: .touchUpInside)
        let currentEventsBarButtomItem = UIBarButtonItem(customView: currentEventsButton)
        self.navigationItem.leftBarButtonItems?.append(currentEventsBarButtomItem)
        
        //setup@pastEventsButton
        pastEventsButton = UIButton()
        pastEventsButton.setTitle("Past", for: .normal)
        pastEventsButton.backgroundColor = .black
        pastEventsButton.addTarget(self, action: #selector(pastEventsButtonPressed), for: .touchUpInside)
        let pastEventsButtonBarButtomItem = UIBarButtonItem(customView: pastEventsButton)
        self.navigationItem.leftBarButtonItems?.append(pastEventsButtonBarButtomItem)
        
        //setup@profileButton
        profileButton = UIButton()
        profileButton.setTitle("👧", for: .normal)
        profileButton.backgroundColor = .black
        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        let profileButtonBarButtomItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.rightBarButtonItem = profileButtonBarButtomItem
        
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
        // download@all_the_user_events_and_set_them_to_view
        self.presenter.setDataToTheView()
        
        //setup@addEventButton
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
    func reloadData() {
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            
        }
    }
    
    //MARK: Button methods
    @objc func addEventButtonPressed() {
        
    }
    @objc func allEventsButtonPressed() {
        
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
        return self.presenter.eventsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as! EventTableViewCell
        cell.eventNameLabel.text = self.presenter.eventsList[indexPath.row].eventName
        cell.venueLabel.text = self.presenter.eventsList[indexPath.row].eventVenue
        cell.eventDateAndTimeLabel.text = "\(self.presenter.eventsList[indexPath.row].eventDate ), \(self.presenter.eventsList[indexPath.row].eventTime)"
        cell.guestsAmountLabel.text = self.presenter.eventsList[indexPath.row].totalGuest
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.showEventGuestlist(event: self.presenter.eventsList[indexPath.row])
    }
}
