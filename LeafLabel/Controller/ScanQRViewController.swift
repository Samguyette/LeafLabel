//
//  ScanQRViewController.swift
//  LeafLabel
//
//  Created by Sam Guyette on 12/11/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate{
    
    var qrID = ""
    var video = AVCaptureVideoPreviewLayer()
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.endEditing(true)
        
        navigationController?.delegate = self

        //open up camera to scan QR
        guard let
            //the camera
            captureDevice = AVCaptureDevice.default(for: .video) else { return }
        let input: AVCaptureDeviceInput
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print("Camera capture error")
            return
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        //makes processing run on main thread
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    //pass qrID to Print VC
                    qrID = object.stringValue!
                    print(qrID)
                    
                    //look at push back in video
                    _ = navigationController?.popViewController(animated: true)
                    session.stopRunning()
                }
            }
        }
    }
}
