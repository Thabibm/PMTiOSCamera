# PMTiOSCamera

Do you want to integrate camera functionality into your project? Well then you are in a right place this project will aid you to integrate camera module as a plug and play code into your project.

Usage Description
- This app need i0S 11 or greater  
- Supports Swift 4.0

Features
- Toggle between front and back camera
- Torch option
- Grid lines
- Tap to focus

Installation
1. Clone the repository and add Camera Module folder into your project

2. Add the following key in to your projects info.plist file

Key - "NSCameraUsageDescription"        value - "(message you want to show to acces device camera when User uses it)" 
  
  with out the above key app would crash when it tries to access camera
  
3. Let your view controller conform to the Camera delegate
  
4. To launch camera add following line in your view controller
  
        CameraManager.sharedInstance.loadCamera(cameraDelegate: self)
      
5. To get Image output add the following method in to your view controller
  
        func didCompleteImageCapture(image: UIImage) {
          //Process the captured image
        }
