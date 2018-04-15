//
//  QRReaderController.swift
//  QRKit
//
//  Created by Drew Wilken on 3/18/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import UIKit
import AVFoundation

//enum for camera position - user of framework can decide the camera position
public enum CameraPosition {
    case front
    case back
}

//protocol that needs to be followed to process QR codes
public protocol QRReaderDelegate {
    func processQR(_ qrString: String)
}

public final class QRReaderController: UIViewController {
    
    private var session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
    }
    
    //Delegate - Should be the app that
    public var delegate: QRReaderDelegate?
    public var Position = CameraPosition.back
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        //delegate?.processQR("Woah there guy, can't find me ;)")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        //delegate will be set to the controller/class that will handle the QR
        //findings
        self.delegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCamera() {
        guard let device = getDevice(with: .back) else {
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
    }
    
    //Get device
    func getDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let discoverySession = self.discoverySession else {
            return nil
        }
        for device in discoverySession.devices {
            if(device.position == position) {
                return device
            }
        }
        return nil
    }
}

// MARK: Metadata Processing

extension QRReaderController: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if (metadataObjects.count == 0) {
            print("No metadata objects found")
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let metadataString = metadataObj.stringValue {
                if let delegate = self.delegate {
                    delegate.processQR(metadataString)
                }
            }
        }
    }
}

