//
//  QRRead.swift
//  QRKit
//
//  Created by Drew Wilken on 3/2/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class QRRead: UIViewController {
    
    var session = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var contactViewFrame: UIView?
    
    @IBOutlet weak var bottomScannerBar: UILabel!
    @IBOutlet weak var topBar: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create a discovery session to find the device
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        print(discoverySession.devices)
        
        guard let device = discoverySession.devices.first else {
            print("Couldn't find rear-facing camera.")
            return
        }
        
        //try creating a new input from the capture device
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            //add the input to the session
            session.addInput(input)
            
            //add the output for the metadata to the session
            let metaDataCapture = AVCaptureMetadataOutput()
            session.addOutput(metaDataCapture)
            
            //set the delegate to self because following the delegate protocol here
            metaDataCapture.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataCapture.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            print(error)
            return
        }
        
        //create the preview layer and add it as a subview
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)
        
        session.startRunning()
        
        view.bringSubview(toFront: bottomScannerBar)
        
        contactViewFrame = UIView()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension QRRead: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if (metadataObjects.count == 0) {
            print("No metadata objects found")
            contactViewFrame?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)
            contactViewFrame?.isHidden = false
            contactViewFrame?.frame = barCodeObject!.bounds
            
        }
    }
}

