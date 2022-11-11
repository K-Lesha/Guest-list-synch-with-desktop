//
//  PasswordModalView.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 24.10.2022.
//

import UIKit
import BottomSheet

protocol PasswordViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: AuthPresenterProtocol! {get set}
    init(initialHeight: CGFloat, presenter: AuthPresenterProtocol, superView: SignInViewProtocol)
    // View properties
    var currentViewHeight: CGFloat! {get set}
    var keyboardHeight: CGFloat! {get set}
    var superView: SignInViewProtocol! {get set}
    //Methods
    func dismissPasswordAndSignInViews()
}


class PasswordModalViewController: UIViewController, PasswordViewProtocol {
    //MARK: -VIPER protocol
    weak internal var presenter: AuthPresenterProtocol!
    //MARK: -View properties
    var currentViewHeight: CGFloat!
    var keyboardHeight: CGFloat!
    weak var superView: SignInViewProtocol!
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
    private var passwordLabel: UILabel!
    private var passwordTextField: UITextField!
    private var createAccountButton: UIButton!
    private var tryToLoginButton: UIButton!
    private var noSuchUserLabel: UILabel!
    private var registerButton: UIButton!
    private var tryAgainButton: UIButton!
    private var errorLabel: UILabel? = nil
    private var forgotPasswordButton: UIButton? = nil
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyBoardNotification()
    }
    //MARK: -METHODS
    //MARK: View methods
    private func setupViews() {
        //mark@view
        view.backgroundColor = .white

        //setup@passwordLabel
        passwordLabel = UILabel()
        view.addSubview(passwordLabel)
        passwordLabel.textColor = .black
        passwordLabel.text = "ПАРОЛЬ"
        passwordLabel.font = Appearance.titlesFont
        //constraints@passwordLabel
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 3).isActive = true
        passwordLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        passwordLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        //setup@passwordTextField
        passwordTextField = UITextField()
        view.addSubview(passwordTextField)
        passwordTextField.placeholder = "пароль"
        passwordTextField.font = Appearance.buttomsFont
        let bottomLine = CALayer()
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.layer.addSublayer(bottomLine)
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        //constraints@passwordTextField
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: passwordLabel.widthAnchor).isActive = true
        let passwordTextfieldHeighConstraint: CGFloat = 20
        passwordTextField.heightAnchor.constraint(equalToConstant: passwordTextfieldHeighConstraint).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: passwordLabel.leftAnchor, constant: 0).isActive = true
        bottomLine.frame = CGRect(x: 0.0, y: passwordTextfieldHeighConstraint, width: view.frame.width - 50, height: 1.0)
        
        //setup@tryToLoginButton
        tryToLoginButton = UIButton()
        view.addSubview(tryToLoginButton)
        tryToLoginButton.setTitle("log in", for: .normal)
        tryToLoginButton.backgroundColor = .white
        tryToLoginButton.titleLabel?.font = Appearance.buttomsFont
        tryToLoginButton.setTitleColor(.orange, for: .normal)
        tryToLoginButton.addTarget(self, action: #selector(tryToLoginWithFirebase), for: .touchUpInside)
        //constraints@tryToLoginButton
        tryToLoginButton.translatesAutoresizingMaskIntoConstraints = false
        tryToLoginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        tryToLoginButton.leftAnchor.constraint(equalTo: passwordTextField.leftAnchor, constant: 0).isActive = true
        tryToLoginButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        tryToLoginButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        //setup@createAccountButton
        createAccountButton = UIButton()
        view.addSubview(createAccountButton)
        createAccountButton.setTitle("создать аккаунт", for: .normal)
        createAccountButton.backgroundColor = .orange
        createAccountButton.titleLabel?.font = Appearance.buttomsFont
        createAccountButton.titleLabel?.textAlignment = .left
        createAccountButton.layer.cornerRadius = 15
        createAccountButton.addTarget(self, action: #selector(tryToRegisterWithFirebase), for: .touchUpInside)
        //constraints@createAccountButton
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        createAccountButton.leftAnchor.constraint(equalTo: tryToLoginButton.rightAnchor).isActive = true
        createAccountButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        createAccountButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
    }
    private func showPasswordError() {
        self.passwordTextField.layer.sublayers?.first?.backgroundColor = UIColor.red.cgColor
        passwordTextField.text = ""
        passwordTextField.placeholder = "Ваш пароль должен быть более 6 символов"
    }
    private func showLoginError() {
        //setup@errorLabel
        errorLabel = UILabel()
        self.view.addSubview(errorLabel ?? UILabel())
        errorLabel?.numberOfLines = 0
        errorLabel?.textColor = .red
        errorLabel?.textAlignment = .left
        errorLabel?.text = "проверьте интернет соединение и корректность введенных данных"
        errorLabel?.font = Appearance.buttomsFont
        //constraints@errorLabel
        errorLabel?.translatesAutoresizingMaskIntoConstraints = false
        errorLabel?.topAnchor.constraint(equalTo: self.createAccountButton.bottomAnchor, constant: 5).isActive = true
        errorLabel?.leftAnchor.constraint(equalTo: self.tryToLoginButton.leftAnchor, constant: 10).isActive = true
        errorLabel?.widthAnchor.constraint(equalToConstant: 250).isActive = true
        errorLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //setup@forgotPasswordButton
        forgotPasswordButton = UIButton()
        self.view.addSubview(forgotPasswordButton ?? UIButton())
        forgotPasswordButton?.setTitle("Я забыл пароль", for: .normal)
        forgotPasswordButton?.backgroundColor = .white
        forgotPasswordButton?.titleLabel?.font = Appearance.buttomsFont
        forgotPasswordButton?.setTitleColor(.orange, for: .normal)
        forgotPasswordButton?.addTarget(self, action: #selector(restorePassword), for: .touchUpInside)
        //constraints@tryToLoginButton
        forgotPasswordButton?.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton?.topAnchor.constraint(equalTo: errorLabel?.bottomAnchor ?? self.createAccountButton.bottomAnchor, constant: 10).isActive = true
        forgotPasswordButton?.leftAnchor.constraint(equalTo: errorLabel?.leftAnchor ?? self.tryToLoginButton.leftAnchor, constant: 0).isActive = true
        forgotPasswordButton?.heightAnchor.constraint(equalToConstant: 35).isActive = true
        forgotPasswordButton?.widthAnchor.constraint(equalToConstant: 160).isActive = true
    }
    private func showAlert(_ success: Bool) {
        var alert = UIAlertController()
        if success {
            alert = UIAlertController(title: "Проверьте почту", message: "на email отправлено письмо со ссылкой для сброса пароля", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
        } else {
            alert = UIAlertController(title: "Невозможно сбросить пароль", message: "проверьте интернет соеденение и корректность введенного имейла", preferredStyle: .alert)
            let backToEmailAction = UIAlertAction(title: "вернуться к вводу email", style: .default) { action in
                self.dismiss(animated: true)
            }
            alert.addAction(backToEmailAction)
        }
        self.present(alert, animated: true)
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
    @objc private func tryToLoginWithFirebase() {
        animateButton(button: tryToLoginButton)
        if checkPasswordTextFeild() {
            presenter.password = self.passwordTextField.text ?? ""
            presenter.tryToLoginWithFirebase { result in
                switch result {
                case .success(_):
                    self.presenter.showEventsListModule()
                    self.dismissPasswordAndSignInViews()
                case .failure(let error):
                    print(error.localizedDescription)
                    self.showLoginError()
                }
            }
        } else {
            return
        }
    }
    @objc private func tryToRegisterWithFirebase() {
        animateButton(button: createAccountButton)
        if checkPasswordTextFeild() {
            passwordTextField.resignFirstResponder()
            presenter.password = self.passwordTextField.text ?? ""
            //change view vize to normal
            preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight)
            //show next modal view
            let viewControllerToPresent = RegistrationModalViewController(initialHeight: 200, presenter: self.presenter, superView: self)
            presentBottomSheetInsideNavigationController(
                viewController: viewControllerToPresent,
                configuration:.init(cornerRadius: 15, pullBarConfiguration: .visible(.init(height: -5)), shadowConfiguration: .default))
        } else {
            return
        }
    }
    private func checkPasswordTextFeild() -> Bool {
        guard let passwordString = self.passwordTextField.text else {
            showPasswordError()
            return false
        }
        if passwordString.count >= 6 {
            passwordTextField.resignFirstResponder()
            return true
        } else {
            showPasswordError()
            return false
        }
    }
    @objc private func restorePassword() {
        presenter.restorePasswordWithFirebase() { result in
            switch result {
            case .success(_):
                self.showAlert(true)
            case .failure(_):
                self.showAlert(false)
            }
        }
    }
    //MARK: -Deinit
    func dismissPasswordAndSignInViews() {
        print("trying to dismiss PasswordModalView")
        self.dismiss(animated: false)
    }
    deinit {
        self.superView.dismissThisView()
        print("PasswordModalViewController was deinited")
    }
}

//MARK: -UITextFieldDelegate
extension PasswordModalViewController: UITextFieldDelegate {
    //textFieldDidEndEditing
    func textFieldDidEndEditing(_ textField: UITextField) {
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: currentViewHeight)
    }
    //textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
            tryToLoginWithFirebase()
        }
        return true
    }
}
