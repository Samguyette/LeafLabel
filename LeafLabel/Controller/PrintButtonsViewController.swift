//
//  PrintButtonsViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 12/11/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit

class PrintButtonsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    @IBAction func goToAdminMenuBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "goToAdminMenu", sender: self)
    }
}
