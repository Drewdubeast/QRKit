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
        setupQR(string: "", color: .red)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        setupQR(string: "", color: .red)
    }

    open func setupQR(string: String, color: UIColor) {
        if let qrImage = generateQRCode(for: string, view: self, for: color) {
            self.image = qrImage
        }
    }
    
    open func recolor(with color: UIColor) {
        guard let image = self.image else {
            return
        }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return
        }
        colorFilter.setValue(image.ciImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
        guard let coloredImage = colorFilter.outputImage else {
            return
        }
        self.image = UIImage(ciImage: coloredImage)
    }
    
    private func generateQRCode(for string: String, view: UIView, for color: UIColor) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            
            guard let colorFilter = CIFilter(name: "CIFalseColor") else {
                return nil
            }

            //set the data to the contact data
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel")

            colorFilter.setValue(filter.outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
            guard let codeImage = colorFilter.outputImage
                else {
                    return nil
            }
            
            //guard let codeImage = filter.outputImage else { return nil }
            
            //size of the contact code image
            let scaleX = view.frame.size.width / codeImage.extent.size.width
            let scaleY = view.frame.size.height / codeImage.extent.size.height
            
            //transform to clear the image up
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            //return the image
            if let output = colorFilter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
