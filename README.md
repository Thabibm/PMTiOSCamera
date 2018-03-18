# PMTiOSCamera

Do you want to integrate camera functionality into your project? Well then you are in a right place this project will aid you to integrate camera module as a plug and play code into your project.

Usage Description
- This app need i0S 8 or greater  
- Supports Swift 4.0

Features
- Toggle between front and back camera
- Torch option
- Grid lines
- Tap to focus

Installation
Clone the repository and add Camer Module folder into your project

add the following key in to your projects info.plist file

Key - "NSCameraUsageDescription"        value - "<message you want to show to acces device camera when User uses it>" 
  
  with out the above key app would crash when it tries to access camera
  
  To launch camera add following line in your view controller
  
      CameraManager.sharedInstance.loadCamera(cameraDelegate: self)
      
  To get Image output add the following method in to your view controller
  
      func didCompleteImageCapture(image: UIImage) {
        //Process the captured image
      }
