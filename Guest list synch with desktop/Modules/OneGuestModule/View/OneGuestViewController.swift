//
//  OneGuestViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 14.11.2022.
//

import UIKit

protocol OneGuestViewPortocol {
    //VIPER protocol
    var presenter: OneGuestPresenterProtocol! {get set}
    //Methods
    func setupGuestOnTheScreen(guest: GuestEntity)
}

class OneGuestViewController: UIViewController, OneGuestViewPortocol {
    
    //MARK: -VIPER PROTOCOL
    var presenter: OneGuestPresenterProtocol!
    
    //MARK: -OUTLETS
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var guestGroupLabel: UILabel!
    @IBOutlet weak var guestPhotoImageView: UIImageView!
    @IBOutlet weak var comapanyNameLabel: UILabel!
    @IBOutlet weak var positionInCompanyLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var internalNotesTextView: UITextView!
    
    @IBOutlet weak var presentGiftButton: UIButton!
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var giftCommentLabel: UILabel!
    @IBOutlet weak var checkinCommentLabel: UILabel!
    
    private var editGuestButton: UIButton!


    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGuestOnTheScreen(guest: presenter.guest)
        setupViews()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }

    //MARK: -METHODS
    // MARK: View methods
    func setupViews() {
        //setup@internalNotesTextView
        internalNotesTextView.isEditable = false
        
        //setup@eventSettingsButton
        editGuestButton = UIButton()
        editGuestButton.setTitle("🖊", for: .normal)
        editGuestButton.backgroundColor = .black
        editGuestButton.addTarget(self, action: #selector(editGuestButtonPushed), for: .touchUpInside)
        let editGuestButtonItem = UIBarButtonItem(customView: editGuestButton)
        self.navigationItem.rightBarButtonItems = [editGuestButtonItem]
    }
    func setupGuestOnTheScreen(guest: GuestEntity) {
        self.nameLabel.text = guest.guestName
        if let surname = guest.guestSurname {
            self.surnameLabel.text = surname
        } else {
            self.surnameLabel.isHidden = true
        }
        if let guestGroup = guest.guestGroup, guestGroup.count > 1 {
            guestGroupLabel.text = guestGroup
        } else {
            guestGroupLabel.text = "группа не присвоена"
            guestGroupLabel.textColor = .gray
        }
        
        if let guestPhotoURL = guest.photoURL {
            presenter.setGuestPhoto(stringURL: guestPhotoURL) { result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.sync {
                            self.guestPhotoImageView.image = image
                        }
                    }
                default:
                    break
                }
            }
        } else {
            
        }
        if let company = guest.companyName, company.count > 1 {
            comapanyNameLabel.text = company
        } else {
            comapanyNameLabel.text = "нет информации о компании"
            comapanyNameLabel.textColor = .gray
        }
        if let position = guest.positionInCompany, position.count > 1 {
            positionInCompanyLabel.text = position
        } else {
            positionInCompanyLabel.text = "неизвестно"
            positionInCompanyLabel.textColor = .gray
        }
        if let phoneNumber = guest.phoneNumber, phoneNumber.count > 1 {
            phoneNumberLabel.text = phoneNumber
        } else {
            phoneNumberLabel.text = "неизвестно"
            phoneNumberLabel.textColor = .gray
        }
        if let email = guest.guestEmail, email.count > 1 {
            emailLabel.text = email
        } else {
            emailLabel.text = "неизвестно"
            emailLabel.textColor = .gray
        }
        if let internalNotes = guest.internalNotes, internalNotes.count > 1 {
            internalNotesTextView.text = internalNotes
        } else {
            internalNotesTextView.text = "заметок нет"
            internalNotesTextView.textColor = .gray
        }
        //checkIn Button
        let guestsAmmount = guest.guestsAmount
        let guestEntered = guest.guestsEntered
        checkinButton.setTitle("""
Зачекинить гостя
\(guestEntered) / \(guestsAmmount)
""", for: .normal)
        checkinButton.titleLabel?.textAlignment = .center
        //presentGift Button
        let giftsGifted = guest.giftsGifted
        presentGiftButton.setTitle("""
Подарить подарок
\(giftsGifted) / \(guestsAmmount)
""", for: .normal)
        presentGiftButton.titleLabel?.textAlignment = .center
        
    }
    //MARK: Button methods

    @IBAction func presentGiftButtonTouchUpInside(_ sender: UIButton) {
        
    }
    
    @IBAction func checkInGuestTouchUpInside(_ sender: UIButton) {
    }
    
    @objc func editGuestButtonPushed() {
        print("editGuestButtonPushed")
    }
    
    
    
    
    
    
}
