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
    init(initialHeight: CGFloat, presenter: AuthPresenterProtocol, superView: PasswordViewProtocol)
    // View properties
    var currentViewHeight: CGFloat! {get set}
    var keyboardHeight: CGFloat! {get set}
    var superView: SignInViewProtocol! {get set}
}
//
//class FinishRegistrationModalView: UIViewController, FinishRegistrationModalViewProtocol {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
