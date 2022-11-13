//
//  AddModifyGuestViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import UIKit


protocol AddModifyGuestViewProtocol {
    //VIPER protocol
    var presenter: AddModifyGuestPresenterProtocol! {get set}
    //Methods
    
}


class AddModifyGuestViewController: UIViewController, AddModifyGuestViewProtocol {
    //MARK: -VIPER protocol
    internal var presenter: AddModifyGuestPresenterProtocol!
    
    //MARK: -OUTLETS
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var surnameTextfield: UITextField!
    @IBOutlet weak var companyTextfield: UITextField!
    @IBOutlet weak var guestPositionTextfield: UITextField!
    @IBOutlet weak var guestGroupTextfield: UITextField!
    @IBOutlet weak var guestsAmountTextfield: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phoneTextfiled: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var internalNotesTextfield: UITextField!
    @IBOutlet weak var saveGuestButton: UIButton!
    @IBOutlet weak var deleteGuestButton: UIButton!
    @IBOutlet weak var saveGuestAndAddOneMoreButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    
    //MARK: -viewDidLoad, -viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        print(self.navigationItem.backButtonTitle)
        print(self.navigationController?.navigationItem.backButtonTitle)

    }
    //MARK: -View methods
    func setupViews() {
        // setup@self.view        
        if presenter.state == .addGuest {
            self.navigationItem.title = "Добавление гостя"
            saveGuestButton.isHidden = false
            deleteGuestButton.isHidden = true
            saveGuestAndAddOneMoreButton.isHidden = false
            saveChangesButton.isHidden = true
        } else if presenter.state == .modifyGuest {
            self.navigationItem.title = "Редактирование гостя"
            setGuestDataToView()
            saveGuestButton.isHidden = false
            deleteGuestButton.isHidden = true
            saveGuestAndAddOneMoreButton.isHidden = true
            saveChangesButton.isHidden = false
        }
    }
    
    
    
    //MARK: GUEST EDITING
    private func setGuestDataToView() {
        if presenter.state == .modifyGuest {
            
        }
    }
    
    
    @IBAction func deleteGuestButtonPushed(_ sender: UIButton) {
        print("deleteGuestButton pushed")
    }
    
    
    @IBAction func saveChangesButtonPushed(_ sender: UIButton) {
        print("saveChangesButtonPushed")
    }
    //MARK: GUEST ADDITION
    
    @IBAction func saveNewGuestButtonPushed(_ sender: UIButton) {
        self.tryToAddNewGuest(sender: sender)
    }
    
    @IBAction func saveNewGuestAddOneMoreButtonPushed(_ sender: UIButton) {
        self.tryToAddNewGuest(sender: sender)
    }
    
    private func tryToAddNewGuest(sender: UIButton) {
        guard presenter.state == .addGuest, self.checkFields() else {
            return
        }
            guard let guestName = nameTextfield.text,
                  let guestStringGroup = guestGroupTextfield.text,
                  let guestGroup = Int(guestStringGroup),
                  let guestsStringAmount = guestsAmountTextfield.text,
                  let guestsAmount = Int(guestsStringAmount)
            else { return }
            
            let guestSurname = surnameTextfield.text

        let guestCompany = companyTextfield.text
            let positionInCompany = guestPositionTextfield.text
            let phoneNumber = phoneTextfiled.text
            let email = emailTextfield.text
            let internalNotes = internalNotesTextfield.text
            
            let guestEntity = GuestEntity(guestName: guestName,
                                          guestSurname: guestSurname,
                                          companyName: guestCompany,
                                          positionInCompany: positionInCompany,
                                          guestGroup: guestGroup,
                                          guestsAmount: guestsAmount,
                                          photoURL: nil,
                                          phoneNumber: phoneNumber,
                                          guestEmail: email,
                                          internalNotes: internalNotes)
        switch sender {
        case saveGuestButton:
            presenter.addNewGuest(guest: guestEntity, completion: saveButtonCompletion)
        case saveGuestAndAddOneMoreButton:
            presenter.addNewGuest(guest: guestEntity, completion: saveAndAddOneMoreGuestCompletion)
        default:
            break
        }
    }
    
    func saveButtonCompletion(result: Result<Bool, GuestlistInteractorError>) -> () {
        switch result {
        case .success(_):
            presenter.popViewController()
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func saveAndAddOneMoreGuestCompletion(result: Result<Bool, GuestlistInteractorError>) -> () {
        switch result {
        case .success(_):
            print("guest saved")
            clearTextfiles()
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func clearTextfiles() {
        nameTextfield.text = ""
        surnameTextfield.text = ""
        companyTextfield.text = ""
        guestPositionTextfield.text = ""
        guestGroupTextfield.text = ""
        guestsAmountTextfield.text = ""
        photoImageView.image = nil
        phoneTextfiled.text = ""
        emailTextfield.text = ""
        internalNotesTextfield.text = ""
    }
    
    //MARK: Checking and handleling errors  methods
    func checkFields() -> Bool {
        //Checking if textfields are OK ...
        guard let guestName = nameTextfield.text, guestName.count >= 1 else {
            handleGuestNameTextfieldError()
            return false
        }
        self.nameTextfield.backgroundColor = .white
        
        guard let guestAmount = guestsAmountTextfield.text, guestAmount.count >= 1 else {
            handleGuestAmountTextfieldError()
            return false
        }
        guestsAmountTextfield.backgroundColor = .white
        
        guard let guestGroup = guestGroupTextfield.text, guestGroup.count >= 1 else {
            handleGuestGroupTextfieldError()
            return false
        }
        guestGroupTextfield.backgroundColor = .white
        
        return true
    }
    func handleGuestNameTextfieldError() {
        self.nameTextfield.backgroundColor = .red
        self.nameTextfield.text = ""
        self.nameTextfield.placeholder = "имя гостя должно содержать не менее 2-х символов"
    }
    func handleGuestAmountTextfieldError() {
        self.guestsAmountTextfield.backgroundColor = .red
        self.guestsAmountTextfield.text = ""
        self.guestsAmountTextfield.placeholder = "количество гостей должно быть больше 0"
    }
    func handleGuestGroupTextfieldError() {
        self.guestGroupTextfield.backgroundColor = .red
        self.guestGroupTextfield.text = ""
        self.guestGroupTextfield.placeholder = "гостю должна быть присвоена группа"
    }
}
