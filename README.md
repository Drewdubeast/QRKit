# QRKit
A framework written for iOS for beginners generating QR codes

### How to Import into project ###
* Download/Clone the project 
* Drag the xcodeproj file and nest it within your project in Xcode
* Click on your xcodeproj in your file hierarchy, and go to the general tab
* Go down to 'Embedded Binaries', and click the +
* Add the QRKit framework
* Go into the view controller you want to use it in, and type `import QRKit`

### How to generate a QR Code ###
* Go to your main.storyboard
* Add a new Image View to your view
* Go to the properties manager and change the class to `QRView`
* Link the view to your ViewController
* Call `setupQR()` on your image view with whatever string you want encoded
* Run!

