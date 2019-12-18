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
import WebKit

class PrintConViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var productNameTextField: UILabel!
    @IBOutlet var labelImageView: UIImageView!
    @IBOutlet var gramsTextField: UITextField!
    @IBOutlet var custNameTextField: UITextField!
    @IBOutlet var textFeildBottomConstraint: NSLayoutConstraint!
    @IBOutlet var printWebView: WKWebView!
    
    var databaseRef: Firestore!
    var storageRef: StorageReference!
    var compProductID = ""
    var qrPulledID = "1234"
    var html = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.gramsTextField.delegate = self
        //refrences to Databases
        databaseRef = Firestore.firestore()
        storageRef = Storage.storage().reference()
        //keyboard listener
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
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
                                    self.labelImageView.image = UIImage(data: data!)!
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

    @IBAction func createCutomLabelBtn(_ sender: Any) {
        dismissKeyboard()
        let text = "Purchased: " + gramsTextField.text! + "g\nOwner: " + custNameTextField.text!
        let image = self.textToImage(drawText: text, inImage: self.labelImageView.image!, atPoint: CGPoint(x: 20, y: 20))
        
        self.labelImageView.image = image
        let data = image.pngData()
        let base64 = data!.base64EncodedString(options: [])
        let url = "data:application/png;base64," + base64
        self.html = "<html><img style='max-width: 840px; height: auto; ' src='\(url)'></html>"
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
        
        //actually print
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary:nil)
        //define print specs
        printInfo.orientation = UIPrintInfo.Orientation.landscape
        printInfo.outputType = .general
        printInfo.jobName = "Print Job"
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        printController.printFormatter = formatter
        printController.present(animated: true, completionHandler: nil)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.textFeildBottomConstraint.constant = 20
        return false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
       let textColor = UIColor.white
       let textFont = UIFont(name: "HiraginoSans-W6", size: 12)!

       let scale = UIScreen.main.scale
       UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

       let textFontAttributes = [
        NSAttributedString.Key.font: textFont,
        NSAttributedString.Key.foregroundColor: textColor,
        ] as [NSAttributedString.Key : Any]
       image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

       let rect = CGRect(origin: point, size: image.size)
       text.draw(in: rect, withAttributes: textFontAttributes)

       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
    }
}

extension ScanQRViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? PrintConViewController)?.qrPulledID = qrID
    }
}
