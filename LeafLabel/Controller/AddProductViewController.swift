//
//  AddProductViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/16/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


class AddProductViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //might need to add more delegates above
    @IBOutlet var productNameTextField: UITextField!
    @IBOutlet var addProductBtn: UIButton!
    @IBOutlet var demoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        productNameTextField.delegate = self
    }
    
    @IBAction func selectImageView(_ sender: Any) {
        let picker = UIImagePickerController()
        self.view.endEditing(true)
        //might need fixing
        picker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        //picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            demoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("selection cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        productNameTextField.isEnabled = false
        addProductBtn.isEnabled = false
        let identifier = ShortCodeGenerator.getCode(length: 10)
        //loading image
        
        //store image
        let image = demoImageView.image
        let imageQR = addQR(image: image!, identifier: identifier)
        let data = imageQR.jpegData(compressionQuality: 1.0)
//        guard let image = demoImageView.image, let data = image.jpegData(compressionQuality: 1.0) else{
//            print("Something went wrong uploading picture.")
//            return
//        }
        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child("imagesFolder").child(imageName)
        
        imageRef.putData(data!, metadata: nil) { (metadata, err) in
            if err != nil{
                print("There was a problem storing picture.")
                return
            }
            imageRef.downloadURL { (url, nil) in
                if err != nil{
                    print("There was a problem storing picture.")
                    return
                }
                guard let url = url else{
                    print("Another error.")
                    return
                }
            
                var userEmail = Auth.auth().currentUser?.email
                let urlString = url.absoluteString
                userEmail = userEmail!.replacingOccurrences(of: ".", with: ",", options: NSString.CompareOptions.literal, range: nil)
                
                
                //let productsDB = Database.database().reference().child(userEmail!)
                let dataRef = Firestore.firestore().collection(userEmail!).document()
                let documentID = dataRef.documentID
                
                let productDict = ["productName": self.productNameTextField.text!, "userProductID": identifier, "compProductID": documentID, "imageURL": urlString, "imageName": imageName, "gramCount": 0, "labelsPrinted": 0, "inStock": 0] as [String : Any]
                
                dataRef.setData(productDict) { (error) in
                    if error != nil{
                        print(error!)
                    } else{
                        print("Product saved successfully")
                        self.productNameTextField.isEnabled = true
                        self.addProductBtn.isEnabled = true
                        self.productNameTextField.text = ""
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //action when text field is clicked
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //action when done editing
    }
    
    struct ShortCodeGenerator {
        private static let base62chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        private static let maxBase : UInt32 = 62

        static func getCode(withBase base: UInt32 = maxBase, length: Int) -> String {
            var code = ""
            for _ in 0..<length {
                let random = Int(arc4random_uniform(min(base, maxBase)))
                code.append(base62chars[random])
            }
            return code
        }
    }
    
    func addQR(image: UIImage, identifier: String) -> UIImage {
        let data = identifier.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        
        let qr = UIImage(ciImage: (filter?.outputImage)!)
        
        let imgQR = image.overlayed(with: qr)
        
        //try to update UIImageView
        let imgQRView = UIImageView(image: imgQR)
        demoImageView = imgQRView
        
        //save image to device
        UIImageWriteToSavedPhotosAlbum(imgQR!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        //return image
        return imgQR!
    }
    
    //helper function to save custom label to photos library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension UIImage {
    func overlayed(with overlay: UIImage) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        overlay.draw(in: CGRect(x: size.width-60, y: 0, width: 60, height: 60))
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return nil
    }
}

