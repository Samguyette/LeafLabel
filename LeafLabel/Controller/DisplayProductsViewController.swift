//
//  DisplayProductsViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/15/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DisplayProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var productArray:[Product] = [Product]()
    @IBOutlet var productTableView: UITableView!
    var databaseRef: Firestore!
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        
        productTableView.delegate = self
        productTableView.dataSource = self
        
        productTableView.register(UINib(nibName: "ProductViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customProductCell")
        
        configureTableView()
        retrieveProducts()
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customProductCell", for: indexPath) as! ProductViewCellTableViewCell
        cell.productName.text = productArray[indexPath.row].productName
        cell.photoImageView.image = productArray[indexPath.row].photoImageView
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    func configureTableView() {
        productTableView.rowHeight = 140.0
        productTableView.estimatedRowHeight = 140.0
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
                        let product = Product()
                        //photo
                        let urlString = data["imageURL"] as! String
                        Storage.storage().reference(forURL: urlString).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                            DispatchQueue.main.async {
                                product.photoImageView = UIImage(data: data!)
                                print("Image loaded")
                                self.productTableView.reloadData()
                            }
                        })
                        
                        //strings
                        product.productName = data["productName"] as! String
                        self.productArray.append(product)
                        self.configureTableView()
                        self.productTableView.reloadData()
                    }
                }
            }
        }
    }
}
