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
    @IBOutlet weak var accessLevelTextfield: UITextField!
    @IBOutlet weak var guestsAmountTextfield: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phoneTextfiled: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var internalNotesTextfield: UITextField!
    
    @IBOutlet weak var saveGuestButton: UIButton!
    @IBOutlet weak var deleteGuestButton: UIButton!
    @IBOutlet weak var saveGuestAndAddOnMoreButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    //MARK: -viewDidLoad, -viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }


   

    //MARK: -View methods
    
    func setupViews() {
        // setup@self.view        
        if presenter.state == .addGuest {
            self.navigationItem.title = "Добавить гостя"
            saveGuestButton.isHidden = false
            deleteGuestButton.isHidden = true
            saveGuestAndAddOnMoreButton.isHidden = false
            saveChangesButton.isHidden = true

        } else if presenter.state == .modifyGuest {
            self.navigationItem.title = "Редактировать гостя"
            setGuestDataToView()
            saveGuestButton.isHidden = false
            deleteGuestButton.isHidden = true
            saveGuestAndAddOnMoreButton.isHidden = true
            saveChangesButton.isHidden = false
        }
        
        
        
    }
    private func setGuestDataToView() {
        
    }

    
}
