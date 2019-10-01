//
//  LoginViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/1/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil{
                print(error!)
            } else{
                print("Login Successful")
                self.performSegue(withIdentifier: "goToMenu", sender: self)
            }
        }
        
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
