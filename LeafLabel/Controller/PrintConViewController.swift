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

    @IBOutlet var productNameTextField: UILabel!
    @IBOutlet var labelImageView: UIImageView!
    @IBOutlet var gramsTextField: UITextField!
    @IBOutlet var textFeildBottomConstraint: NSLayoutConstraint!
    
    var databaseRef: Firestore!
    var storageRef: StorageReference!
    var compProductID = ""
    var qrPulledID = "1234"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.gramsTextField.delegate = self
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        //keyboard listener
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear is running")
        print(qrPulledID)
        
        var userEmail = Auth.auth().currentUser?.email
        userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
        
        databaseRef.collection(userEmail!).getDocuments() { (snapshot, error) in

            if let error = error {
                print(error.localizedDescription)
            } else {

                if let snapshot = snapshot {

                    for document in snapshot.documents {
                        let data = document.data()
                        //where QR code data replaces
                        if data["userProductID"] as? String == self.qrPulledID{
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
    
    @IBAction func searchBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCamera", sender: self)
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
        self.textFeildBottomConstraint.constant = 20
        return false
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let info = notification.userInfo{
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.textFeildBottomConstraint.constant = rect.height + 5
            })
        }
    }
}

extension ScanQRViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? PrintConViewController)?.qrPulledID = qrID
    }
}
