Pod::Spec.new do |s|
  s.name         = "QRKit"
  s.version      = "1.0.0"
  s.summary      = "A framework written for iOS for beginners using QR code scanning and generating them"
  s.description  = "A QR code framework written in swift for iOS that aids in generating and reading QR codes"
  s.homepage     = "https://github.com/Drewdubeast/QRKit"
  s.license      = "MIT"
  s.author       = { "Drew Wilken" => "hdwdrew@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "11.0"
  s.swift_version = "4.0"
  s.source       = { :git => "https://github.com/Drewdubeast/QRKit.git", :tag => "#{s.version}" }
  s.source_files  = "QRKit/*.swift"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
end
