//
//  QRGen.swift
//  QRKit
//
//  Created by Drew Wilken on 3/2/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation
import UIKit

class QRGen: UIImage {
    
    func generateContactCode(for string: String,_ view: UIView) -> UIImage? {
        
        let data = string.data(using: String.Encoding.ascii) //(String.Encoding.isoLatin1)
        
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
