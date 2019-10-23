//
//  DisplayProductsViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/15/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import Firebase

class DisplayProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var productArray:[Product] = [Product]()
    @IBOutlet var productTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productTableView.delegate = self
        productTableView.dataSource = self
        
        productTableView.register(UINib(nibName: "ProductViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProductCell")
        
        configureTableView()
        retrieveProducts()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProductCell", for: indexPath) as! ProductViewCellTableViewCell
        cell.productName.text = productArray[indexPath.row].productName
        cell.productID.text = productArray[indexPath.row].productID
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    func configureTableView() {
        productTableView.rowHeight = 120.0
        productTableView.estimatedRowHeight = 120.0
    }
    
    func retrieveProducts(){
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        let productDB = Database.database().reference().child(userEmail!)
        
        productDB.observe(.childAdded) { (snapshot) in
            //will have to change dictionary type for pictures later
            //look at the end of lecture 426
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let name = snapshotValue["ProductName"]!
            let id = snapshotValue["ProductID"]!
            
            let product = Product()
            product.productName = name
            product.productID = id
            
            self.productArray.append(product)
            self.configureTableView()
            self.productTableView.reloadData()
        }
    }
}
