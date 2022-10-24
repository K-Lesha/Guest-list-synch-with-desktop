//
//  RegistrationModalView.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import UIKit

protocol RegistrationViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: AuthPresenterProtocol! {get set}
    init(initialHeight: CGFloat, presenter: AuthPresenterProtocol)
    // View properties
    var currentViewHeight: CGFloat! {get set}
    var keyboardHeight: CGFloat! {get set}
}


class RegistrationModalViewController: UIViewController, RegistrationViewProtocol {
    //MARK: VIPER protocol
    weak internal var rootViewContoroller: PasswordViewProtocol!
    weak internal var presenter: AuthPresenterProtocol!
    //MARK: View properties
    internal var currentViewHeight: CGFloat!
    internal var keyboardHeight: CGFloat!
    //MARK: INIT
    required init(initialHeight: CGFloat, presenter: AuthPresenterProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: initialHeight)
        currentViewHeight = initialHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: OUTLETS
    private var registerLabel: UILabel!
    private var emailTextfield: UITextField!
    private var passwordTextfield: UITextField!
    private var userNameTextfield: UITextField!
    private var registerButton: UIButton!
    private var errorLabel: UILabel? = nil
    
    //MARK: viewDidLoad
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
        registerLabel.text = "ONE MORE STEP"
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
        
        //setup@passwordTextfield
        passwordTextfield = UITextField()
        view.addSubview(passwordTextfield)
        passwordTextfield.placeholder = "password"
        if presenter.password.count > 0 {
            passwordTextfield.text = self.presenter.password
        }
        passwordTextfield.isSecureTextEntry = true
        passwordTextfield.font = Appearance.buttomsFont
        passwordTextfield.autocorrectionType = .no
        passwordTextfield.borderStyle = UITextField.BorderStyle.none
        let bottomLinePassword = CALayer()
        bottomLinePassword.backgroundColor = UIColor.lightGray.cgColor
        passwordTextfield.layer.addSublayer(bottomLinePassword)
        passwordTextfield.delegate = self
        //constraints@passwordTextfield
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.topAnchor.constraint(equalTo: emailTextfield.bottomAnchor, constant: 10).isActive = true
        passwordTextfield.widthAnchor.constraint(equalTo: emailTextfield.widthAnchor).isActive = true
        passwordTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: emailTextfield.leftAnchor, constant: 0).isActive = true
        bottomLinePassword.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@userNameTextfield
        userNameTextfield = UITextField()
        view.addSubview(userNameTextfield)
        userNameTextfield.placeholder = "username (optional)"
        userNameTextfield.font = Appearance.buttomsFont
        userNameTextfield.borderStyle = UITextField.BorderStyle.none
        let bottomLineLoginEmail = CALayer()
        bottomLineLoginEmail.backgroundColor = UIColor.lightGray.cgColor
        userNameTextfield.layer.addSublayer(bottomLineLoginEmail)
        userNameTextfield.delegate = self
        userNameTextfield.autocorrectionType = .no
        //constraints@userNameTextfield
        userNameTextfield.translatesAutoresizingMaskIntoConstraints = false
        userNameTextfield.topAnchor.constraint(equalTo: passwordTextfield.bottomAnchor, constant: 10).isActive = true
        userNameTextfield.widthAnchor.constraint(equalTo: passwordTextfield.widthAnchor).isActive = true
        userNameTextfield.heightAnchor.constraint(equalToConstant: textfieldsHeighConstraint).isActive = true
        userNameTextfield.leftAnchor.constraint(equalTo: passwordTextfield.leftAnchor, constant: 0).isActive = true
        bottomLineLoginEmail.frame = CGRect(x: 0.0, y: textfieldsHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@nextButton
        registerButton = UIButton()
        view.addSubview(registerButton)
        registerButton.setTitle("register", for: .normal)
        registerButton.titleLabel?.font = Appearance.buttomsFont
        registerButton.backgroundColor = .orange
        registerButton.layer.cornerRadius = 15
        registerButton.addTarget(self, action: #selector(tryToRegisterWithFirebase), for: .touchUpInside)
        //constraints@nextButton
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: userNameTextfield.bottomAnchor, constant: 5).isActive = true
        registerButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        registerButton.leftAnchor.constraint(equalTo: userNameTextfield.leftAnchor, constant: 0).isActive = true
        
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
    private func showRegistrationError() {
        //setup@errorLabel
        errorLabel = UILabel()
        self.view.addSubview(errorLabel ?? UILabel())
        errorLabel?.numberOfLines = 0
        errorLabel?.textColor = .red
        errorLabel?.textAlignment = .left
        errorLabel?.text = "check the Internet connection and the correctness of the entered data"
        errorLabel?.font = Appearance.buttomsFont
        //constraints@errorLabel
        errorLabel?.translatesAutoresizingMaskIntoConstraints = false
        errorLabel?.topAnchor.constraint(equalTo: self.registerButton.topAnchor, constant: 0).isActive = true
        errorLabel?.leftAnchor.constraint(equalTo: self.registerButton.rightAnchor, constant: 10).isActive = true
        errorLabel?.widthAnchor.constraint(equalToConstant: 250).isActive = true
        errorLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    private func handleEmailTextFieldError() {
        self.emailTextfield.layer.sublayers?.first?.backgroundColor = UIColor.red.cgColor
        self.emailTextfield.text = ""
        self.emailTextfield.placeholder = "email should be correct"
    }
    private func handlePasswordTextFieldError() {
        self.passwordTextfield.layer.sublayers?.first?.backgroundColor = UIColor.red.cgColor
        self.passwordTextfield.text = ""
        self.passwordTextfield.placeholder = "Your password must be longer than 6 characters"
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
        print("keyboardWillShow ", Thread.current)
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight + keyboardHeight)
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight )
        }
    }
    //MARK: Button methods
    @objc private func tryToRegisterWithFirebase() {
        animateButton(button: registerButton)
        // hide keyboard
        emailTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        userNameTextfield.resignFirstResponder()
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
        var flag = true
        switch emailTextfield.text {
        case (let text) where text?.count == 0:
            self.handleEmailTextFieldError()
            flag = false
        case (let text) where !self.isValidEmail(email: text ?? ""):
            self.handleEmailTextFieldError()
            flag = false
        case (_) where self.passwordTextfield.text == nil:
            self.handlePasswordTextFieldError()
            flag = false
        case (_) where (self.passwordTextfield.text?.count ?? 0) < 6:
            self.handlePasswordTextFieldError()
            flag = false
        case nil:
            self.handleEmailTextFieldError()
            flag = false
        default: return true
        }
        return flag
    }
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    //MARK: NAVIGATION
    private func continueToRegistration() {
        // sending to presenter all the parameters
        if self.userNameTextfield.text?.count != 0, self.userNameTextfield.text != nil {
            presenter.userName = self.userNameTextfield.text!
        } else {
            presenter.userName = "noname"
        }
        presenter.password = self.passwordTextfield.text!
        presenter.email = self.emailTextfield.text!
        errorLabel?.removeFromSuperview()
        errorLabel = nil
        // try to registrer
        presenter.tryToRegisterWithFirebase() { result in
            switch result {
                //if success -> show next VC
            case .success(_):
                print("RegistrationViewController: tryToRegisterWithFirebase() case .success", Thread.current)
                // in succesfull case -> SceneDelegate {Auth.auth().addStateDidChangeListener} -> will change the state of app
            case.failure(_):
                self.showRegistrationError()
            }
        }
    }
    //MARK: Deinit
    deinit {
        print("RegistrationModalViewController was deinited")
    }
}

//MARK: UITextFieldDelegate
extension RegistrationModalViewController: UITextFieldDelegate {
    //textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        //loginTextField
        if self.emailTextfield.text != nil || (self.emailTextfield.text?.count ?? 0) > 0 {
            emailTextfield.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
        }
        // passwordTextfield
        if self.passwordTextfield.text != nil || (self.passwordTextfield.text?.count ?? 0) > 0 {
            passwordTextfield.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
        }
        // emailTextfield
        if textField == self.userNameTextfield {
            userNameTextfield.resignFirstResponder()
        }
        if self.userNameTextfield.text != nil || (self.userNameTextfield.text?.count ?? 0) > 0 {
            userNameTextfield.layer.sublayers?.first?.backgroundColor = UIColor.lightGray.cgColor
        }
    }
    //textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextfield {
            passwordTextfield.becomeFirstResponder()
        }
        if textField == self.passwordTextfield {
            userNameTextfield.becomeFirstResponder()
        }
        if textField == self.userNameTextfield {
            tryToRegisterWithFirebase()
        }
        return true
    }
}

