//
//  DashboardTableViewCell.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/26/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DashboardTableViewCell: UITableViewCell {

    
    @IBOutlet var productName: UILabel!
    @IBOutlet var productID: UILabel!
    @IBOutlet var gramCount: UILabel!
    @IBOutlet var labelsPrinted: UILabel!
    @IBOutlet var inStockSwitch: UISwitch!
    
    var databaseRef: Firestore!
    var storageRef: StorageReference!
    
    var compProductID = ""
    var inStock = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        databaseRef.collection(userEmail!).getDocuments() { (snapshot, error) in

            if let error = error {
                print(error.localizedDescription)
            } else {

                if let snapshot = snapshot {

                    for document in snapshot.documents {
                        let data = document.data()
                        self.compProductID = data["compProductID"] as! String
                        self.inStock = data["inStock"] as! Int
                    }
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchChange(_ sender: Any) {
        //refrences to Databases
        //pull referecned cell ID
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        databaseRef.collection(userEmail!).getDocuments() { (snapshot, error) in

            if let error = error {
                print(error.localizedDescription)
            } else {

                if let snapshot = snapshot {

                    for document in snapshot.documents {
                        let data = document.data()
                        print(data["userProductID"] as! String)
                        print(self.productID.text!)
                        let pulledID = data["userProductID"] as! String
                        if pulledID.contains(self.productID.text!) {
                            print("HH")
                            self.compProductID = data["compProductID"] as! String
                            self.inStock = data["inStock"] as! Int
                        }
                    }
                }
            }
        }

        let ref = databaseRef.collection(userEmail!).document(compProductID)
        if inStock == 1 {
            inStock = inStock-1
            ref.updateData(["inStock": FieldValue.increment(Int64(-1))])
        } else {
            inStock = inStock+1
            ref.updateData(["inStock": FieldValue.increment(Int64(1))])
        }
    }
}
