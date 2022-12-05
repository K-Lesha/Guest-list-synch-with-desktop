//
//  OneGuestViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 14.11.2022.
//

import UIKit

protocol OneGuestViewPortocol: AnyObject {
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
        setupViews()
        setupGuestOnTheScreen(guest: presenter.guest)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateGuestDataOnTheScreen()
    }

    //MARK: -METHODS
    // MARK: View methods
    func setupViews() {
        //setup@internalNotesTextView
        internalNotesTextView.isEditable = false
        
        //setup@editGuestButton
        editGuestButton = UIButton()
        editGuestButton.setTitle("🖊", for: .normal)
        editGuestButton.backgroundColor = .black
        editGuestButton.addTarget(self, action: #selector(editGuestButtonPushed), for: .touchUpInside)
        let editGuestButtonItem = UIBarButtonItem(customView: editGuestButton)
        self.navigationItem.rightBarButtonItems = [editGuestButtonItem]
    }
    func setupGuestOnTheScreen(guest: GuestEntity) {
        if guest.guestsAmount == 0 {
            self.view.backgroundColor = .lightGray
        }
        self.nameLabel.text = guest.name
        if let surname = guest.surname {
            self.surnameLabel.text = surname
        } else {
            self.surnameLabel.isHidden = true
        }
        if let guestGroup = guest.group, guestGroup.count > 1 {
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
        if let company = guest.company, company.count > 0 {
            comapanyNameLabel.text = company
        } else {
            comapanyNameLabel.text = "нет информации о компании"
            comapanyNameLabel.textColor = .gray
        }
        if let position = guest.position, position.count > 0 {
            positionInCompanyLabel.text = position
        } else {
            positionInCompanyLabel.text = "неизвестно"
            positionInCompanyLabel.textColor = .gray
        }
        if let phoneNumber = guest.phoneNumber, phoneNumber.count > 0 {
            phoneNumberLabel.text = phoneNumber
        } else {
            phoneNumberLabel.text = "неизвестно"
            phoneNumberLabel.textColor = .gray
        }
        if let email = guest.email, email.count > 0 {
            emailLabel.text = email
        } else {
            emailLabel.text = "неизвестно"
            emailLabel.textColor = .gray
        }
        if let internalNotes = guest.internalNotes, internalNotes.count >= 0 {
            internalNotesTextView.text = internalNotes
        } else {
            internalNotesTextView.text = "заметок нет"
            internalNotesTextView.textColor = .gray
        }
        //checkIn Button
        setTitleForCheckInButton(guestEntered: guest.guestsEntered, guestsAmmount: guest.guestsAmount)
        checkinButton.titleLabel?.textAlignment = .center
        //presentGift Button
        setTitleForGiftsButton(giftsGifted: guest.giftsGifted, guestsAmmount: guest.guestsAmount)
        presentGiftButton.titleLabel?.textAlignment = .center
        //all the buttons
        self.checkGuestAmountForButtons()
        setLongGestureRecognisersForTheButtons()
    }
    func updateGuestDataOnTheScreen() {
        self.presenter.updateGuestData { result in
            switch result {
            case .success(let guest):
                self.presenter.guest = guest
                self.setupGuestOnTheScreen(guest: guest)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    //MARK: -Button view methods
    //Guest check-in/out button
    private func setTitleForCheckInButton(guestEntered: Int, guestsAmmount: Int) {
        checkinButton.setTitle("""
                                Зачекинить гостя
                                \(guestEntered) / \(guestsAmmount)
                                """, for: .normal)
    }
    
    //Gift button
    private func setTitleForGiftsButton(giftsGifted: Int, guestsAmmount: Int) {
        self.presentGiftButton.setTitle("""
                            Подарить подарок
                            \(giftsGifted) / \(guestsAmmount)
                            """, for: .normal)
    }
    // All the buttons
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            button.transform = .init(scaleX: 1.25, y: 1.25)
        }) { (finished: Bool) -> Void in
            button.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                button.transform = .identity
            })
        }
    }
    private func checkGuestAmountForButtons() {
        if presenter.guest.giftsGifted >= presenter.guest.guestsAmount {
            self.presentGiftButton.backgroundColor = .gray
        } else {
            self.presentGiftButton.backgroundColor = .blue
        }
        self.presentGiftButton.isEnabled = true
        if presenter.guest.guestsEntered >= presenter.guest.guestsAmount {
            self.checkinButton.backgroundColor = .gray
        } else {
            self.checkinButton.backgroundColor = .blue
        }
        self.checkinButton.isEnabled = true
    }
    //MARK: Button action methods
    //Gift button
    @IBAction func presentGiftButtonTouchUpInside(_ sender: UIButton) {
        animateButton(presentGiftButton)
        guard presenter.guest.giftsGifted < presenter.guest.guestsAmount else {
            self.checkGuestAmountForButtons()
            return
        }
        self.presentGiftButton.isEnabled = false
        self.presentGiftButton.backgroundColor = .gray
        
        presenter.presentOneGift { string in
            //TODO: обработка ошибок
            print("added")
            self.presenter.guest.giftsGifted += 1
            self.setTitleForGiftsButton(giftsGifted: self.presenter.guest.giftsGifted, guestsAmmount: self.presenter.guest.guestsAmount)
            self.checkGuestAmountForButtons()
        }
    }
    @objc private func ungiftGifts() {
        animateButton(presentGiftButton)
        guard self.presenter.guest.giftsGifted > 0 else {
            return
        }
        self.presentGiftButton.isEnabled = false
        self.presentGiftButton.backgroundColor = .gray
        presenter.ungiftAllTheGifts { string in
            print(string)
            self.presenter.guest.giftsGifted = 0
            self.setTitleForGiftsButton(giftsGifted: self.presenter.guest.giftsGifted, guestsAmmount: self.presenter.guest.guestsAmount)
            self.checkGuestAmountForButtons()
        }
    }
    //Guest check-in/out button
    @IBAction func checkInGuestTouchUpInside(_ sender: UIButton) {
        animateButton(checkinButton)
        guard presenter.guest.guestsEntered < presenter.guest.guestsAmount else {
            self.checkGuestAmountForButtons()
            return
        }
        self.checkinButton.isEnabled = false
        self.checkinButton.backgroundColor = .gray
        presenter.oneGuestEntered { string in
            //TODO: обработка ошибок
            print("added")
            self.presenter.guest.guestsEntered += 1
            self.setTitleForCheckInButton(guestEntered: self.presenter.guest.guestsEntered, guestsAmmount: self.presenter.guest.guestsAmount)
            self.checkGuestAmountForButtons()
        }
    }
    @objc private func checkoutGuests() {
        animateButton(checkinButton)
        guard self.presenter.guest.guestsEntered > 0 else {
            return
        }
        self.checkinButton.isEnabled = false
        self.checkinButton.backgroundColor = .gray
        presenter.canselAllTheGuestCheckins { string in
            print(string)
            self.presenter.guest.guestsEntered = 0
            self.setTitleForCheckInButton(guestEntered: self.presenter.guest.guestsEntered, guestsAmmount: self.presenter.guest.guestsAmount)
            self.checkGuestAmountForButtons()
        }
    }
    //All the buttons
    private func setLongGestureRecognisersForTheButtons() {
        let ungiftGesture = UILongPressGestureRecognizer(target: self, action: #selector(ungiftGifts))
        self.presentGiftButton.addGestureRecognizer(ungiftGesture)
        
        let checkoutGesture = UILongPressGestureRecognizer(target: self, action: #selector(checkoutGuests))
        self.checkinButton.addGestureRecognizer(checkoutGesture)
    }
    @objc func editGuestButtonPushed() {
        presenter.showGuestEditModule()
    }
    
    //MARK: Deinit
    deinit {
        print("OneGuestViewController was deinited")
    }
}
