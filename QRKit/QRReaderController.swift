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
    func processQR(_ qrString: String, with controller: UIViewController)
}

public final class QRReaderController: UIViewController {
    
    //create inputs and outputs
    var input: AVCaptureDeviceInput?
    let metaDataCaptureOutput = AVCaptureMetadataOutput()
    
    //Delegate - Should be the app that
    public var delegate: QRReaderDelegate?
    
    fileprivate var metadataLastString: String?
    
    fileprivate var session = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var discoverySession: AVCaptureDevice.DiscoverySession? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
    }
    
    var position: CameraPosition = .back {
        
        //if the camera's position was changed, then stop it and update it
        didSet {
            if self.session.isRunning {
                self.session.stopRunning()
                updateCamera()
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        updateCamera()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCamera() {
        
        //reset inputs
        if let currentInput = self.input {
            self.session.removeInput(currentInput)
        }
        //gets device based on position input
        guard let device = getDevice(with: position == .back ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front) else {
            return
        }
        
        //try creating a new input from the capture device
        do {
            //create inputs and outputs
            let input = try AVCaptureDeviceInput(device: device)
            
            if(session.canAddInput(input) && session.canAddOutput(metaDataCaptureOutput)) {
                //add the input to the session
                session.addInput(input)
                
                //add the output for the metadata to the session
                session.addOutput(metaDataCaptureOutput)
                
                session.commitConfiguration()
                session.startRunning()
            }
            
            //set the delegate to self because following the delegate protocol here
            metaDataCaptureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataCaptureOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            print(error)
            return
        }
        
        guard let previewLayer = getPreviewLayer() else {
            return
        }
        view.layer.addSublayer(previewLayer)
    }
    
    //gets the preview layer for the QR reader
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        
        //create the preview layer and add it as a subview
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        
        return previewLayer
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
                
                if(metadataLastString != metadataString) {
                    metadataLastString = metadataString
                    
                    if let delegate = self.delegate {
                        delegate.processQR(metadataString, with: self)
                    }
                }
            }
        }
    }
}

