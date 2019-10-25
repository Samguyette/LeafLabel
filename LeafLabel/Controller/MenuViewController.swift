//
//  MenuViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/1/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MenuViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    

    @IBAction func logOffPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch{
            print("Couldn't signout")
        }
    }
    
}
