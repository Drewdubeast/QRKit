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
    var currentColor: UIColor?
    
    open var qrimage: UIImage {
        return self.image!
    }
    
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
    
    //recolor the image (since we use a filter, if we keep recoloring same image it fades,
    //so just recreate the image everytime with a new color
    open func recolor(with color: UIColor) {
        guard self.image != nil else {
            print("You must call setupQR before you can recolor anything!")
            return
        }
        guard let string = self.string else {
            print("You must call setupQR before you can recolor anything!")
            return
        }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            print("Could not create color filter")
            return
        }
        if let image = generateQRCode(for: string, view: self, for: color) {
            colorFilter.setValue(image.ciImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
            guard let coloredImage = colorFilter.outputImage else {
                return
            }
            self.image = UIImage(ciImage: coloredImage)
        }
    }
    
    private func generateQRCode(for string: String, view: UIView, for color: UIColor) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii)
        
        self.string = string
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {

            //set the data to the contact data
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel")

            guard let codeImage = filter.outputImage
                else {
                    return nil
            }
            
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
