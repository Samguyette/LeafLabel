//
//  AddProductViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/16/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import Firebase

class AddProductViewController: UIViewController, UITextFieldDelegate {

    //might need to add more delegates above
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var addProductBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productNameTextField.delegate = self
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        productNameTextField.isEnabled = false
        addProductBtn.isEnabled = false
        
        let identifier = ShortCodeGenerator.getCode(length: 8)
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        let productsDB = Database.database().reference().child(userEmail!)
        let productDict = ["ProductName": productNameTextField.text!, "ProductID": identifier]
        
        //creates random key for product
        productsDB.childByAutoId().setValue(productDict){
            (error, refrence) in
            if error != nil{
                print(error!)
            } else{
                print("Product saved successfully")
                self.productNameTextField.isEnabled = true
                self.addProductBtn.isEnabled = true
                self.productNameTextField.text = ""
            }
        }
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //action when text field is clicked
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //action when done editing
    }
    
    struct ShortCodeGenerator {
        private static let base62chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        private static let maxBase : UInt32 = 62

        static func getCode(withBase base: UInt32 = maxBase, length: Int) -> String {
            var code = ""
            for _ in 0..<length {
                let random = Int(arc4random_uniform(min(base, maxBase)))
                code.append(base62chars[random])
            }
            return code
        }
    }
}
