//
//  DisplayProductsViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/15/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit

class DisplayProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var productTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productTableView.delegate = self
        productTableView.dataSource = self
        
        productTableView.register(UINib(nibName: "ProductViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProductCell")
        
        configureTableView()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProductCell", for: indexPath) as! ProductViewCellTableViewCell
        let productArray = ["First", "Second", "Third"]
        cell.productName.text = productArray[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func configureTableView() {
        productTableView.rowHeight = UITableView.automaticDimension
        productTableView.estimatedRowHeight = 120.0
    }
}
