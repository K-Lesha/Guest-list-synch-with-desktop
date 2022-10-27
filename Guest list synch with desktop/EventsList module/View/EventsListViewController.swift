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
    
    //MARK: VIPER protocol
    internal var presenter: EventsListPresenterProtocol!
    
    //MARK: View properties
    var eventsList: [EventEntity] = [EventEntity(eventName: "testEvent"), EventEntity(eventName: "testEvent2"), EventEntity(eventName: "testEvent3")]
    let utils = Utils()
    let sheetsService = GoogleSpreadsheetsService()
    
    //MARK: OUTLETS
    internal var eventsTableView: UITableView!
    internal var sheetsButton: UIButton!
    
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    //MARK: METHODS
    //MARK: View methods
    private func setupViews() {
        //setup@self.view
        self.view.backgroundColor = .white
        
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
        eventsTableView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: -150).isActive = true
        
        //setup@sheetsButton
        sheetsButton = UIButton()
        self.view.addSubview(sheetsButton)
        sheetsButton.setTitle("LOAD SHEETS", for: .normal)
        sheetsButton.backgroundColor = .black
        sheetsButton.addTarget(self, action: #selector(showSpreadsheetsController), for: .touchUpInside)
        //constraints@sheetsButton
        sheetsButton.translatesAutoresizingMaskIntoConstraints = false
        sheetsButton.topAnchor.constraint(equalTo: eventsTableView.bottomAnchor, constant: 10).isActive = true
        sheetsButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        sheetsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sheetsButton.centerXAnchor.constraint(equalTo: eventsTableView.centerXAnchor).isActive = true
    }
    
    
    //MARK: Button methods
    @objc func showSpreadsheetsController() {
        print("readData")
        sheetsService.readData(range: .oneEventData) { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
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
        return cell
    }
    
    
}



class Utils {
    
    func showAlert(title : String, message: String, vc: UIViewController) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
    }
}
