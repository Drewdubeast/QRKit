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
    
    // MARK : PIXEL PROCESSING
    open func recolor(to color: UIColor) -> UIImage? {
        
        //credit to @Rob on StackOverflow for this function

        guard let ciImage = self.image?.ciImage else {
            print("Can not get image data")
            return nil
        }
        
        //create cgImage from ciImage of the QRCode
        let ciContext = CIContext(options: nil)
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        
        guard let inputCGImage = cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                if pixelBuffer[offset] == .black {
                    pixelBuffer[offset] = uiColorComponents(color: color)
                }
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: (image?.scale)!, orientation: (image?.imageOrientation)!)
        
        self.image = outputImage
        return outputImage
    }
    
    struct RGBA32: Equatable {
        private var color: UInt32
        
        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }
        
        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }
        
        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }
        
        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }
        
        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }
        
        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
        
        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        static func == (lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
    
    func uiColorComponents(color: UIColor) -> RGBA32 {
        return RGBA32(red: UInt8(color.cgColor.components![0]),
                      green: UInt8(color.cgColor.components![1]),
                      blue: UInt8(color.cgColor.components![2]),
                      alpha: UInt8(color.cgColor.components![3]))
    }
}
