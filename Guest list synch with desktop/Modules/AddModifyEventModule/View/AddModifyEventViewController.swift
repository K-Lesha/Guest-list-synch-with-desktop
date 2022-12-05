//
//  AddModifyEventViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 16.11.2022.
//

import UIKit

protocol AddModifyEventViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: AddModifyEventPresenterProtocol! {get set}
}

class AddModifyEventViewController: UIViewController, AddModifyEventViewProtocol {

    //MARK: -VIPER protocol
    var presenter: AddModifyEventPresenterProtocol!
    
    //MARK: -OUTLETS
    @IBOutlet weak var eventNameTextfield: UITextField!
    @IBOutlet weak var venueNameTextfield: UITextField!
    @IBOutlet weak var eventDateTextfield: UITextField!
    @IBOutlet weak var eventTimeTextfield: UITextField!
    @IBOutlet weak var eventClientTextfield: UITextField!
    @IBOutlet weak var synchWithGoogleSwitch: UISwitch!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var addNewEventButton: UIButton!
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    //MARK: -COMMON VIEW METHODS
    //View methods
    func setupViews() {
        if presenter.state == .createEvent {
            deleteButton.isEnabled = false
            deleteButton.isHidden = true
            saveChangesButton.isEnabled = false
            saveChangesButton.isHidden = true
            addNewEventButton.isHidden = false
            addNewEventButton.isEnabled = true
        } else if presenter.state == .modifyEvent {
            deleteButton.isEnabled = true
            deleteButton.isHidden = false
            saveChangesButton.isEnabled = true
            saveChangesButton.isHidden = false
            addNewEventButton.isEnabled = false
            addNewEventButton.isHidden = true
            setEventDataToTheScreen()
        }
        
    }
    //Button methods
    
    
    //MARK: -EVENT EDITING METHODS
    //View methods
    func setEventDataToTheScreen() {
        guard presenter.state == .modifyEvent,
            let event = presenter.eventEntity
        else {
            return
        }
        eventNameTextfield.text = event.name
        venueNameTextfield.text = event.venue
        eventDateTextfield.text = event.date
        eventTimeTextfield.text = event.time
        eventClientTextfield.text = event.client
        //TODO: synchWithGoogleSwitch = event.isOnline
    }
    //Button methods
    @IBAction func deleteEventButtonPushed(_ sender: Any) {
        presenter.deleteEvent { string in
            print(string)
            self.presenter.router.showEventsListModule()
        }
    }
    
    @IBAction func saveChangesButtonPushed(_ sender: Any) {
        guard checkTextfields(),
              let oldEventEntity = presenter.eventEntity,
              let eventName = eventNameTextfield.text,
              let eventDate = eventDateTextfield.text
        else {
            return
        }
        
        var newEventEntity = oldEventEntity
        newEventEntity.name = eventName
        newEventEntity.date = eventDate
        newEventEntity.venue = venueNameTextfield.text ?? " "
        newEventEntity.time = eventTimeTextfield.text ?? " "
        newEventEntity.client = eventClientTextfield.text ?? " "
        
        self.presenter.newEventData = newEventEntity
        
        presenter.modifyEvent { string in
            print(string)
            self.presenter.popThisModule()
        }
    }
    
    
    
    //MARK: -EVENT ADDING METHODS
    //View methods

    //Button methods
    @IBAction func addNewEventButtonPushed(_ sender: Any) {
        guard checkTextfields(),
              let eventName = eventNameTextfield.text,
              let eventDate = eventDateTextfield.text
        else {
            return
        }
        addNewEventButton.isEnabled = false
        addNewEventButton.backgroundColor = .gray
        
        let eventVenue = venueNameTextfield.text
        let eventTime = eventTimeTextfield.text
        let eventClient = eventClientTextfield.text
        let isOnlineEvent = synchWithGoogleSwitch.isOn
        
        presenter.addNewEvent(eventName: eventName,
                              eventVenue: eventVenue,
                              eventDate: eventDate,
                              eventTime: eventTime,
                              eventClient: eventClient,
                              isOnline: isOnlineEvent) { result in
            switch result {
            case .success(_):
                self.presenter.popThisModule()
            case.failure(_):
//                handleError()
                print("fail")
            }
        }
    }

    //MARK: -Checking and handleling errors  methods
    //View methods
    private func checkTextfields() -> Bool {
        var flag = true
        if let eventName = eventNameTextfield.text, eventName.count >= 1 {
            self.eventNameTextfield.backgroundColor = .white
        } else {
            flag = false
            handleEventNameTextfieldError()
        }
        if let eventDate = eventDateTextfield.text, eventDate.count >= 2 {
            self.eventDateTextfield.backgroundColor = .white
        } else {
            flag = false
            handleEventDateTextfieldError()
        }
        return flag
    }
    private func handleEventNameTextfieldError() {
        self.eventNameTextfield.backgroundColor = .red
        self.eventNameTextfield.text = ""
        self.eventNameTextfield.placeholder = "имя гостя должно содержать не менее 2-х символов"
    }
    private func handleEventDateTextfieldError() {
        self.eventDateTextfield.backgroundColor = .red
        self.eventDateTextfield.text = ""
        self.eventDateTextfield.placeholder = "имя гостя должно содержать не менее 2-х символов"
    }

    //MARK: Deinit
    deinit {
        print("AddModifyEventViewController was deinited")
    }
    
}
