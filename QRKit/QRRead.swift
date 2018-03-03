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

public final class QRRead: UIViewController {
    
    var session = AVCaptureSession()
    var codeViewFrame: UIView?
    var captureDevice: AVCaptureDevice?
    
    var codeString: String?
    
    var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
    }
    var metaDataCapture = AVCaptureMetadataOutput()
    
    //initializer for the reading framework
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.codeString = nil
        
        //get everything running
        createCameraView()
        configure()
    }
    //required init
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //return the preview layer for the camera
    public func getPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = self.view.bounds
        
        return previewLayer
    }
    
    public func createCameraView() {
        self.view.layer.addSublayer(getPreviewLayer(session: self.session))
    }
    
    //returns a device!
    func getDevice() -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession else {
            return nil
        }
        for device in discoverySession.devices {
            if (device.position == .back) {
                captureDevice = device
                return device
            }
        }
        return nil
    }
    
    func configure() {
        do {
            guard let captureDevice = getDevice() else {
                return
            }
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //add the input to the session
            
            //session.addInput(input)
            
            //add the output for the metadata to the session
            let output = AVCaptureMetadataOutput()
            metaDataCapture.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataCapture.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //if all is good, then add inputs and outputs and commit
            if (self.session.canAddInput(input) && self.session.canAddOutput(metaDataCapture)) {
                self.session.addInput(input)
                self.session.addOutput(output)
                self.session.commitConfiguration()
                self.session.startRunning()
            }
        } catch {
            print(error)
            return
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //try creating a new input from the capture device
        
        codeViewFrame = UIView()
        
        if let codeViewFrame = codeViewFrame {
            codeViewFrame.layer.borderColor = UIColor.green.cgColor
            codeViewFrame.layer.borderWidth = 4
            view.addSubview(codeViewFrame)
            view.bringSubview(toFront: codeViewFrame)
        }
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension QRRead: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if (metadataObjects.count == 0) {
            print("No metadata objects found")
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = getPreviewLayer(session: self.session).transformedMetadataObject(for: metadataObj)
            codeViewFrame?.isHidden = false
            codeViewFrame?.frame = barCodeObject!.bounds
            
            if let codeString = metadataObj.stringValue {
                print(codeString)
                self.codeString = codeString
            }
        }
    }
}
