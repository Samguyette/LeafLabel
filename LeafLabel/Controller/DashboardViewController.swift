//
//  DashboardViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/26/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var productArray:[DashboardProduct] = [DashboardProduct]()
    @IBOutlet var dashboardTableView: UITableView!
    var databaseRef: Firestore!
    var storageRef: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        
        dashboardTableView.register(UINib(nibName: "DashboardTableViewCell", bundle: nil), forCellReuseIdentifier: "customDashboardCell")
        
        configureTableView()
        retrieveProducts()
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customDashboardCell", for: indexPath) as! DashboardTableViewCell
        cell.productName.text = productArray[indexPath.row].productName
        cell.productID.text = productArray[indexPath.row].productID
        if productArray[indexPath.row].inStock {
            cell.inStockSwitch.setOn(true, animated: false)
        } else {
            cell.inStockSwitch.setOn(false, animated: false)
        }
        cell.labelsPrinted.text = "\(productArray[indexPath.row].labelsPrinted)"
        cell.gramCount.text = "\(productArray[indexPath.row].gramCount)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    func configureTableView() {
        dashboardTableView.rowHeight = 120.0
        dashboardTableView.estimatedRowHeight = 120.0
    }

    func retrieveProducts(){
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        databaseRef.collection(userEmail!).getDocuments() { (snapshot, error) in

            if let error = error {

                print(error.localizedDescription)

            } else {

                if let snapshot = snapshot {

                    for document in snapshot.documents {

                        let data = document.data()
                        let dashboardProduct = DashboardProduct()
                        //photo
                        let urlString = data["imageURL"] as! String
                        Storage.storage().reference(forURL: urlString).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            DispatchQueue.main.async {
                                dashboardProduct.photoImageView = UIImage(data: data!)
                                print("Image loaded")
                                self.dashboardTableView.reloadData()
                            }
                        })
                        
                        //strings
                        dashboardProduct.productName = "Name: " + (data["productName"] as! String)
                        dashboardProduct.productID = "Product ID: " + (data["userProductID"] as! String)
                        dashboardProduct.gramCount = data["gramCount"] as! Int    
                        dashboardProduct.labelsPrinted = data["labelsPrinted"] as! Int
                        if data["inStock"] as! Int == 0 {
                            dashboardProduct.inStock = false
                        } else {
                            dashboardProduct.inStock = true
                        }
                        
                        self.productArray.append(dashboardProduct)
                        self.configureTableView()
                        self.dashboardTableView.reloadData()
                    }
                }
            }
        }
    }
}
