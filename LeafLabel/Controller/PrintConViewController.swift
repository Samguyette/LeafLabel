//
//  PrintConViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/26/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class PrintConViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var productNameTextField: UILabel!
    @IBOutlet var labelImageView: UIImageView!
    @IBOutlet var gramsTextField: UITextField!
    
    var databaseRef: Firestore!
    var storageRef: StorageReference!
    var compProductID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.gramsTextField.delegate = self
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
    }
    
    
    @IBAction func searchBtn(_ sender: Any) {
        self.view.endEditing(true)
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        databaseRef.collection(userEmail!).getDocuments() { (snapshot, error) in

            if let error = error {
                print(error.localizedDescription)
            } else {

                if let snapshot = snapshot {

                    for document in snapshot.documents {
                        let data = document.data()
                        if data["userProductID"] as? String == self.codeTextField.text{
                            self.compProductID = data["compProductID"] as! String
                            //photo
                            let urlString = data["imageURL"] as! String
                            Storage.storage().reference(forURL: urlString).getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                                DispatchQueue.main.async {
                                    self.labelImageView.image = UIImage(data: data!)
                                    print("Image found.")
                                }
                            })
                            self.productNameTextField.text = data["productName"] as? String
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func printBtn(_ sender: Any) {
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        let ref = databaseRef.collection(userEmail!).document(compProductID)
        let gramsInt: Int? = Int(gramsTextField.text!)
        var x = 0
        while x < gramsInt!{
            ref.updateData([
                "gramCount": FieldValue.increment(Int64(1))
            ])
            x = x+1
        }
        ref.updateData([
            "labelsPrinted": FieldValue.increment(Int64(1))
        ])
        print("Counts updated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
