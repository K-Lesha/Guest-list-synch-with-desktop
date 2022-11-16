//
//  AddModifyEventViewController.swift
//  Guest list synch with desktop
//
//  Created by Алексей Коваленко on 16.11.2022.
//

import UIKit

protocol AddModifyEventViewProtocol {
    //VIPER protocol
    var presenter: AddModifyEventPresenterProtocol! {get set}
}

class AddModifyEventViewController: UIViewController, AddModifyEventViewProtocol {

    //MARK: -VIPER protocol
    var presenter: AddModifyEventPresenterProtocol!
    
    //MARK: -OUTLETS
    
    
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: -COMMON VIEW METHODS
    //View methods
    
    //Button methods
    
    
    //MARK: -EVENT EDITING METHODS
    //View methods
    
    //Button methods


    
    
    //MARK: -EVENT ADDING METHODS
    //View methods

    //Button methods

    
    //MARK: -Checking and handleling errors  methods
    //View methods
    
    //Button methods

}
