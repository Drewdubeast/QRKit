//
//  QRGen.swift
//  QRKit
//
//  Created by Drew Wilken on 3/2/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
import UIKit

public class QRView: UIImageView {

    var string: String?

    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        setupQR(string: "")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        setupQR(string: "")
    }

    open func setupQR(string: String) {
        if let qrImage = generateQRCode(for: string, view: self) {
            self.image = qrImage
        }
    }
    
    private func generateQRCode(for string: String, view: UIView) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            
            //set the data to the contact data
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel")
            
            guard let codeImage = filter.outputImage else { return nil }
            
            //size of the contact code image
            let scaleX = view.frame.size.width / codeImage.extent.size.width
            let scaleY = view.frame.size.height / codeImage.extent.size.height
            
            //transform to clear the image up
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            //return the image
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
