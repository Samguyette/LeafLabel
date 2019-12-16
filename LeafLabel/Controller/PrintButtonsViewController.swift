//
//  PrintButtonsViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 12/11/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseAuth

class PrintButtonsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        var name = ""
        var at = true
        for (_, char) in userEmail!.enumerated() {
            if String(char) == "@" {
                at = false
            }
            if at {
                name = name + String(char)
            }
        }
        self.title = "Welcome, "+name
    }
    
    @IBAction func goToAdminMenuBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "goToAdminMenu", sender: self)
    }
}
