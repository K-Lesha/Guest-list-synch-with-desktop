//
//  GuestsStaticticViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 02.11.2022.
//

import UIKit

protocol GuestStatisticViewProtocol: AnyObject {
    //VIPER protocol
    var presenter: GuestlistPresenterProtocol! {get set}
    //Methods
}


class GuestsStaticticViewController: UIViewController, GuestStatisticViewProtocol {
    var presenter: GuestlistPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        print("GuestsStaticticViewController")
        self.title = "Statictic"

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
