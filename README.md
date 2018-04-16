# QRKit #

A simple, lightweight framework written for beginners to work with QR Codes - reading and generating. *It is currently a work in progress and works, but still a work in progress*

## What's Included ##
The framework includes dual functionality - generating and reading QR codes.

## Installation/Integration ##
I will soon include carthage and cocoapod compatibility, but as of now, this is not in it's fully stable release.

### Embedded Binaries ###
* Download/Clone the project 
* Drag the xcodeproj file and nest it within your project in Xcode
* Click on your xcodeproj in your file hierarchy, and go to the general tab
* Go down to 'Embedded Binaries', and click the +
* Add the QRKit framework
* Go into the view controller you want to use it in, and type `import QRKit`

### Cocoapods ###

To install using CocoaPods, create a `Podfile` in your root project directory with the following contents, replacing `MYAPP` with your project name:
```
target 'MYAPP' do
    use_frameworks!
    pod 'QRKit', '~> 1.0'
end
```

Then, once you have this created, in your terminal:

```$ pod install```


## Usage ##
Using QRKit is easy, and requires little code compared to the full code required to do these without QRKit. So far, QRKit supports QR generating and reading.

Here is a sample app that uses the framework: https://github.com/Drewdubeast/QRKitSample

### How to generate a QR Code ###
* Go to your main.storyboard
* Add a new Image View to your view
* Go to the properties manager and change the class of the image view to `QRView`
* Link the view to your ViewController
* Call `setupQR()` on your image view with whatever string you want encoded
  * For example: `myImageView.setupQR(string: "Hello, world!")`
  * Your `ViewController` will look like this:
  ```swift
  import UIKit
  import QRKit

  class QRGenViewController: UIViewController {

    @IBOutlet weak var QRSampleView: QRView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //generate the QR code
        QRSampleView.setupQR(string: "Hello, World!")
    }
  }
  ```
* Run!

## How to read and process QR Codes ##

This is done simply by presenting the QR Reader included in the framework. This should be done in the `ViewDidAppear()` function like so:

```swift
override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //create camera view controller
        let camera = QRReaderController.init()
        
        //show the camera view controller
        present(camera, animated: true, completion: nil)
}
```

### To process QR codes ###
Whenever a QR code is scanned and it has data, the delegate's `processQR()` is called. So, in order to be able to process and do things when a QR code is scanned, your `ViewController` must be set as the delegate.

To set your view controller as the delegate, your `ViewController` must conform to the `QRReaderDelegate` protocol:
```swift
public protocol QRReaderDelegate {
    func processQR(_ qrString: String, with controller: UIViewController)
}
```

A typical and simple way to do this would be to write an extension to your `ViewController` like such:
```swift
//delegate to handle QR findings - must implement in order to be able to process QR code findings.
extension ViewController: QRReaderDelegate {
    func processQR(_ qrString: String, with controller: UIViewController) {
        print(qrString)
    } 
}
```
The above implementation would just print the QR data, but a more realistic way to do it would be to handle it with an alert controller, like such:
```swift
//delegate to handle QR findings - must implement in order to be able to process QR code findings.
extension ViewController: QRReaderDelegate {
    func processQR(_ qrString: String, with controller: UIViewController) {
        let alert = UIAlertController(title: "FOUND A CODE BOI", message: qrString, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
        
        controller.present(alert, animated: true)
    } 
}
```

This means that whenever a QR is scanned and read, it calls this method in your `ViewController`, so whatever you write in this function will happen everytime a new QR is read.

Once you have conformed to the protocol, you can set the framework's view's delegate to `self` like such:

```swift
//create camera view controller
let camera = QRReaderController.init()
        
//set delegate to self (so that when a QR code is read, it sends the data to this class
camera.delegate = self
```


## Contributions ##
I'm always open to contributions and growing this idea. As new as it is, I'm trying to grow it into something that is usable by a lot of people and something that is genuinely helpful. As of now, it is a cool idea, but not necessarily the *most* helpful thing. 

To contribute, open an issue requesting it, and I'll invite you as a contributor. Thanks a ton!
