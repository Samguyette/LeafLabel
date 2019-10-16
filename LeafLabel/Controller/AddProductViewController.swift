//
//  AddProductViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/16/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit

class AddProductViewController: UIViewController, UITextFieldDelegate {

    //might need to add more delegates above
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var addProductBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productNameTextField.delegate = self
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //action when text field is clicked
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //action when done editing
    }
}
