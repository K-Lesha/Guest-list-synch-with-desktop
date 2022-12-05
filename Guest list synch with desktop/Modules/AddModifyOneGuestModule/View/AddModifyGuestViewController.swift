//
//  AddModifyGuestViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 03.11.2022.
//

import UIKit


protocol AddModifyGuestViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: AddModifyGuestPresenterProtocol! {get set}
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
    private var photoURLString: String!
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
    }
    //MARK: -COMMON VIEW METHODS
    func setupViews() {
        if presenter.state == .addGuest {
            // setup@self.view
            self.navigationItem.title = "Добавление гостя"
            //setup@buttons
            saveGuestButton.isHidden = false
            saveGuestAndAddOneMoreButton.isHidden = false
            deleteGuestButton.isHidden = true
            saveChangesButton.isHidden = true
        } else if presenter.state == .modifyGuest {
            // setup@self.view
            self.navigationItem.title = "Редактирование гостя"
            setGuestDataToView()
            //setup@buttons
            saveChangesButton.isHidden = false
            deleteGuestButton.isHidden = false
            saveGuestButton.isHidden = true
            saveGuestAndAddOneMoreButton.isHidden = true
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
    //MARK: -GUEST EDITING METHODS
    //MARK: View methods
    private func setGuestDataToView() {
        if presenter.state == .modifyGuest {
            guard let guest = presenter.guest else {
                return
            }
            // Name
            nameTextfield.text = guest.name
            // optional Surname
            if let surname = guest.surname {
                surnameTextfield.text = surname
            }
            // optional Company
            if let company = guest.company {
                companyTextfield.text = company
            }
            //optional Position
            if let position = guest.position {
                guestPositionTextfield.text = position
            }
            //optional Group
            if let group = guest.group {
                guestGroupTextfield.text = group
            }
            // Amount
            guestsAmountTextfield.text = String(guest.guestsAmount)
            // optional photo
            if let photoURL = guest.photoURL {
                photoURLString = photoURL
                presenter.downloadGuestPhoto(stringURL: photoURL) { result in
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.sync {
                                self.photoImageView.image = image
                            }
                        }
                    default:
                        break
                    }
                }
            }
            //optional Phone
            if let phone = guest.phoneNumber {
                phoneTextfiled.text = phone
            }
            //optional Email
            if let email = guest.email {
                emailTextfield.text = email
            }
            //optional Internal notes
            if let internalNotes = guest.internalNotes {
                internalNotesTextfield.text = internalNotes
            }
        }
    }
    //MARK: Button methods
    @IBAction func deleteGuestButtonPushed(_ sender: UIButton) {
        presenter.deleteGuest() { string in
            self.presenter.popViewController()
        }
    }
    @IBAction func saveChangesButtonPushed(_ sender: UIButton) {
        
        guard presenter.state == .modifyGuest,
                self.checkFields(),
                var modifiedGuest = presenter.guest
        else {
            return
        }
        modifiedGuest.name = nameTextfield.text ?? " "
        modifiedGuest.surname = surnameTextfield.text
        modifiedGuest.company = companyTextfield.text
        modifiedGuest.position = guestPositionTextfield.text
        modifiedGuest.group = guestGroupTextfield.text
        let guestsStringAmount: String = guestsAmountTextfield.text ?? "1"
        modifiedGuest.guestsAmount = Int(guestsStringAmount)!
        modifiedGuest.photoURL = self.photoURLString
        modifiedGuest.phoneNumber = phoneTextfiled.text
        modifiedGuest.email = emailTextfield.text
        modifiedGuest.internalNotes = internalNotesTextfield.text

        presenter.modifiedGuestData = modifiedGuest
        presenter.modifyGuest() { string in
            print("guest modified")
            self.presenter.guest = modifiedGuest
            self.presenter.popViewController()
        }
    }
    //MARK: -GUEST ADDITION METHODS
    //MARK: Button methods
    @IBAction func saveNewGuestButtonPushed(_ sender: UIButton) {
        self.tryToAddNewGuest(sender: sender)
    }
    
    @IBAction func saveNewGuestAddOneMoreButtonPushed(_ sender: UIButton) {
        self.tryToAddNewGuest(sender: sender)
    }
    private func tryToAddNewGuest(sender: UIButton) {
        saveGuestButton.isEnabled = false
        saveGuestAndAddOneMoreButton.isEnabled = false
        
        guard presenter.state == .addGuest,
              self.checkFields(),
              let guestName = nameTextfield.text,
              let guestGroup = guestGroupTextfield.text,
              let guestsStringAmount = guestsAmountTextfield.text,
              let guestsAmount = Int(guestsStringAmount)
        else {
            saveGuestButton.isEnabled = true
            saveGuestAndAddOneMoreButton.isEnabled = true
            return
        }
        
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
                                          internalNotes: internalNotes,
                                          guestRowInSpreadSheet: nil)
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
            saveGuestButton.isEnabled = true
            saveGuestAndAddOneMoreButton.isEnabled = true
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    //MARK: -Checking and handleling errors  methods
    func checkFields() -> Bool {
        var flag = true
        //Checking if textfields are OK ...
        if let guestName = nameTextfield.text, guestName.count >= 2 {
            self.nameTextfield.backgroundColor = .white
        } else {
            flag = false
            handleGuestNameTextfieldError()
        }
        
        if let guestAmount = guestsAmountTextfield.text, guestAmount.count >= 1 {
            guestsAmountTextfield.backgroundColor = .white

        } else {
            handleGuestAmountTextfieldError()
            flag = false
        }
        return flag
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
    //MARK: Deinit
    deinit {
        print("AddModifyGuestViewController was deinited")
    }
}
