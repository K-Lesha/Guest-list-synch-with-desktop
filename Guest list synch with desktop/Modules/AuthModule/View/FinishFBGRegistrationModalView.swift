//
//  FinishRegistrationViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 07.11.2022.
//

import UIKit

protocol FinishRegistrationModalViewProtocol {
    //VIPER protocol
    var presenter: AuthPresenterProtocol! {get set}
    var superView: SignInViewProtocol! {get set}
    //init
    init(initialHeight: CGFloat, presenter: AuthPresenterProtocol, superView: SignInViewProtocol)
    // View properties
    var currentViewHeight: CGFloat! {get set}
    var keyboardHeight: CGFloat! {get set}

}

class FinishRegistrationModalView: UIViewController, FinishRegistrationModalViewProtocol {
    //MARK: -VIPER protocol
    var presenter: AuthPresenterProtocol!
    var superView: SignInViewProtocol!
    
    //MARK: -View properties
    var currentViewHeight: CGFloat!
    var keyboardHeight: CGFloat!

    //MARK: -INIT
    required init(initialHeight: CGFloat, presenter: AuthPresenterProtocol, superView: SignInViewProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: initialHeight)
        currentViewHeight = initialHeight
        self.superView = superView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -OUTLETS
    private var registerLabel: UILabel!
    private var emailTextfield: UITextField!
    private var userNameTextfield: UITextField!
    private var userSurnameTextfield: UITextField!
    private var agencyTextfield: UITextField!
    private var userTypeTextfield: UITextField!
    private var userTypePicker: UIPickerView!
    private var userTypeState: UserTypes?
    private var finishRegistrationButton: UIButton!

    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyBoardNotification()
    }
    
    //MARK: METHODS
    //MARK: View methods
    private func setupViews() {
        //mark@view
        view.backgroundColor = .white
        
        //setup@registerLabel
        registerLabel = UILabel()
        view.addSubview(registerLabel)
        registerLabel.textColor = .black
        registerLabel.text = "ЕЩË ОДИН ШАГ"
        registerLabel.font = Appearance.titlesFont
        //constraints@registerLabel
        registerLabel.translatesAutoresizingMaskIntoConstraints = false
        registerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 3).isActive = true
        registerLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        registerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        registerLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        //setup@emailTextfield
        emailTextfield = UITextField()
        view.addSubview(emailTextfield)
        emailTextfield.placeholder = "email"
        emailTextfield.text = presenter.email
        emailTextfield.font = Appearance.buttomsFont
        emailTextfield.clearButtonMode = .whileEditing
        emailTextfield.keyboardType = .emailAddress
        //TODO: НЕЛЬЗЯ РЕДАКТИРОВАТЬ ЧЕРЕЗ ДЕЛЕГАТ
        let bottomLineLogin = CALayer()
        bottomLineLogin.backgroundColor = UIColor.lightGray.cgColor
        emailTextfield.borderStyle = UITextField.BorderStyle.none
        emailTextfield.layer.addSublayer(bottomLineLogin)
        emailTextfield.delegate = self
        emailTextfield.autocorrectionType = .no
        //constraints@emailTextfield
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.topAnchor.constraint(equalTo: registerLabel.bottomAnchor, constant: 10).isActive = true
        emailTextfield.widthAnchor.constraint(equalTo: registerLabel.widthAnchor).isActive = true
        let textfieldsHeighConstraint: CGFloat = 20
        emailTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        emailTextfield.leftAnchor.constraint(equalTo: registerLabel.leftAnchor, constant: 0).isActive = true
        bottomLineLogin.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@userNameTextfield
        userNameTextfield = UITextField()
        view.addSubview(userNameTextfield)
        userNameTextfield.placeholder = "имя"
        userNameTextfield.font = Appearance.buttomsFont
        userNameTextfield.borderStyle = UITextField.BorderStyle.none
        userNameTextfield.clearButtonMode = .whileEditing
        userNameTextfield.text = presenter.userName
        let bottomLineLoginEmail = CALayer()
        bottomLineLoginEmail.backgroundColor = UIColor.lightGray.cgColor
        userNameTextfield.layer.addSublayer(bottomLineLoginEmail)
        userNameTextfield.delegate = self
        userNameTextfield.autocorrectionType = .no
        //constraints@userNameTextfield
        userNameTextfield.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfield.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor, constant: 10).isActive = true
        userNameTextfield.widthAnchor.constraint(equalTo: emailTextfield.widthAnchor).isActive = true
        userNameTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        userNameTextfield.leftAnchor.constraint(equalTo: emailTextfield.leftAnchor, constant: 0).isActive = true
        bottomLineLoginEmail.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@userSurnameTextfield
        userSurnameTextfield = UITextField()
        view.addSubview(userSurnameTextfield)
        userSurnameTextfield.placeholder = "фамилия (опционально)"
        userSurnameTextfield.font = Appearance.buttomsFont
        userSurnameTextfield.borderStyle = UITextField.BorderStyle.none
        let bottomLineSurnameTextfield = CALayer()
        bottomLineSurnameTextfield.backgroundColor = UIColor.lightGray.cgColor
        userSurnameTextfield.layer.addSublayer(bottomLineSurnameTextfield)
        userSurnameTextfield.delegate = self
        userSurnameTextfield.autocorrectionType = .no
        userSurnameTextfield.clearButtonMode = .whileEditing
        //constraints@userSurnameTextfield
        userSurnameTextfield.translatesAutoresizingMaskIntoConstraints = false
        userSurnameTextfield.topAnchor.constraint(equalTo: userNameTextfield.bottomAnchor, constant: 10).isActive = true
        userSurnameTextfield.widthAnchor.constraint(equalTo: userNameTextfield.widthAnchor).isActive = true
        userSurnameTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        userSurnameTextfield.leftAnchor.constraint(equalTo: userNameTextfield.leftAnchor, constant: 0).isActive = true
        bottomLineSurnameTextfield.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)

        //setup@agencyTextfield
        agencyTextfield = UITextField()
        view.addSubview(agencyTextfield)
        agencyTextfield.placeholder = "агентство (опционально)"
        agencyTextfield.font = Appearance.buttomsFont
        agencyTextfield.borderStyle = UITextField.BorderStyle.none
        let bottomLineAgencyTextfield = CALayer()
        bottomLineAgencyTextfield.backgroundColor = UIColor.lightGray.cgColor
        agencyTextfield.layer.addSublayer(bottomLineAgencyTextfield)
        agencyTextfield.delegate = self
        agencyTextfield.autocorrectionType = .no
        agencyTextfield.clearButtonMode = .whileEditing
        //constraints@agencyTextfield
        agencyTextfield.translatesAutoresizingMaskIntoConstraints = false
        agencyTextfield.topAnchor.constraint(equalTo: userSurnameTextfield.bottomAnchor, constant: 10).isActive = true
        agencyTextfield.widthAnchor.constraint(equalTo: userSurnameTextfield.widthAnchor).isActive = true
        agencyTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        agencyTextfield.leftAnchor.constraint(equalTo: userSurnameTextfield.leftAnchor, constant: 0).isActive = true
        bottomLineAgencyTextfield.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@userTypePicker
        userTypePicker = UIPickerView()
        userTypePicker.delegate = self
        userTypePicker.dataSource = self
        
        //setup@userTypeTextfield
        userTypeTextfield = UITextField()
        view.addSubview(userTypeTextfield)
        userTypeTextfield.placeholder = "тип пользователя"
        userTypeTextfield.font = Appearance.buttomsFont
        userTypeTextfield.borderStyle = UITextField.BorderStyle.none
        userTypeTextfield.clearButtonMode = .whileEditing
        userTypeTextfield.delegate = self
        userTypeTextfield.autocorrectionType = .no
        userTypeTextfield.inputView = userTypePicker
        let bottomLineuserTypeTextField = CALayer()
        bottomLineuserTypeTextField.backgroundColor = UIColor.lightGray.cgColor
        userTypeTextfield.layer.addSublayer(bottomLineuserTypeTextField)
        //constraints@userTypeTextfield
        userTypeTextfield.translatesAutoresizingMaskIntoConstraints = false
        userTypeTextfield.topAnchor.constraint(equalTo: agencyTextfield.bottomAnchor, constant: 15).isActive = true
        userTypeTextfield.widthAnchor.constraint(equalTo: userSurnameTextfield.widthAnchor).isActive = true
        userTypeTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        userTypeTextfield.leftAnchor.constraint(equalTo: userSurnameTextfield.leftAnchor, constant: 0).isActive = true
        bottomLineuserTypeTextField.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        
        //setup@nextButton
        finishRegistrationButton = UIButton()
        view.addSubview(finishRegistrationButton)
        finishRegistrationButton.setTitle("зарегистрироваться", for: .normal)
        finishRegistrationButton.titleLabel?.font = Appearance.buttomsFont
        finishRegistrationButton.backgroundColor = .orange
        finishRegistrationButton.layer.cornerRadius = 15
        finishRegistrationButton.addTarget(self, action: #selector(finishRegistrationButtonPushed), for: .touchUpInside)
        //constraints@nextButton
        finishRegistrationButton.translatesAutoresizingMaskIntoConstraints = false
        finishRegistrationButton.topAnchor.constraint(equalTo: userTypeTextfield.bottomAnchor, constant: 5).isActive = true
        finishRegistrationButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
        finishRegistrationButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        finishRegistrationButton.leftAnchor.constraint(equalTo: userNameTextfield.leftAnchor, constant: 0).isActive = true
    }
    private func animateButton(button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            button.transform = .init(scaleX: 1.25, y: 1.25)
        }) { (finished: Bool) -> Void in
            button.isHidden = false
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                button.transform = .identity
            })
        }
    }
    private func handleUserNameTextFieldError() {
        self.userNameTextfield.layer.sublayers?.first?.backgroundColor = UIColor.red.cgColor
        self.userNameTextfield.text = ""
        self.userNameTextfield.placeholder = "пожалуйста, введите имя пользователя"
    }
    private func handleUserTypeTextFieldError() {
        self.userTypeTextfield.layer.sublayers?.first?.backgroundColor = UIColor.red.cgColor
        self.userTypeTextfield.text = ""
        self.userTypeTextfield.placeholder = "пожалуйста, выберете тип пользователя"
    }

    //MARK: Keyboard methods
    private func setupKeyBoardNotification() {
        //Notification keyboardWillShow
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        //Notification UIKeyboardWillHide
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight + keyboardHeight)
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight)
        }
    }
    

    //MARK: Button methods
    @objc private func finishRegistrationButtonPushed() {
        animateButton(button: finishRegistrationButton)
        // hide keyboard
        self.view.endEditing(true)
        //turn view size back to normal
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight)
        //Checking if textfield empty ...
        if checkTextFields() {
            continueToRegistration()
        } else {
            return
        }
    }
    // MARK: Other methods
    private func checkTextFields() -> Bool {
        //Checking if textfields are OK ...
        guard let userName = self.userNameTextfield.text, userName.count >= 2 else {
            self.handleUserNameTextFieldError()
            return false
        }
        self.userNameTextfield.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
        
        guard let userType = self.userTypeTextfield.text, userType.count > 1 else {
            handleUserTypeTextFieldError()
            return false
        }
        self.userTypeTextfield.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
        return true
    }
    //MARK: NAVIGATION
    private func continueToRegistration() {
        // send to presenter all the parameters
        //name
        if let userName = self.userNameTextfield.text, userName.count >= 1 {
            presenter.userName = userName
        } else {
            return
        }
        //surname
        if let userSurname = self.userSurnameTextfield.text {
            presenter.userSurname = userSurname
        }
        //agency
        if let userAgency = self.agencyTextfield.text {
            presenter.userAgency = userAgency
        }
        // userType
        guard userTypeTextfield.text?.isEmpty == false else {
            return
        }
        // userType already sent with picker
        // try to finish registration registrer
        finishRegistration()
    }
    func finishRegistration() {
        presenter.finishFacebookGoogleRegistrationProcess { result in
            switch result {
            case .success(_):
                self.presenter.showEventsListModule()
                self.dismiss(animated: true)
            case .failure(_):
                print("error")
            }
        }
    }
    //MARK: Deinit
    deinit {
        self.superView.dismissThisView()
        print("FinishRegistrationModalViewController was deinited")
    }
}

//MARK: UITextFieldDelegate
extension FinishRegistrationModalView: UITextFieldDelegate {
    //textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.checkTextFields()
    }
    //textFieldShouldBeginEditing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextfield:
            return false
        default:
            return true
        }
    }
    //textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.userNameTextfield:
            self.userSurnameTextfield.becomeFirstResponder()
        case self.userSurnameTextfield:
            self.agencyTextfield.becomeFirstResponder()
        case self.agencyTextfield:
            self.userTypeTextfield.becomeFirstResponder()
        default:
            break
        }
        return true
    }
}

extension FinishRegistrationModalView: UIPickerViewDataSource, UIPickerViewDelegate {
    //UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UserTypes.count
    }
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return UserTypes(rawValue: row)?.description
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userTypeTextfield.text = UserTypes(rawValue: row)?.description
        self.presenter.userType = UserTypes(rawValue: row)!
//        self.userTypeTextfield.resignFirstResponder()
    }
}
