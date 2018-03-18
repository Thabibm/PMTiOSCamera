//
//  CameraManager.swift
//  CustomCamera
//
//  Created by Peer Mohamed Thabib on 3/9/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate {
    
    //MARK: Private variables
    private let captureSession = AVCaptureSession()
    private let imageOutput = AVCapturePhotoOutput()
    private var cameraPreview : CameraPreview?
    private var delegate : UIViewController!
    private var cameraType : AVCaptureDevice.Position!
    private var placeHolderView : UIView?
        
    //MARK: Singleton Instance
    static var sharedInstance : CameraManager = CameraManager()
    
    private override init() {
        super.init()
    }
    
    func removeCameraManager() {
        NotificationCenter.default.removeObserver(self)
        self.captureSession.stopRunning()
        self.placeHolderView!.removeFromSuperview()
        self.delegate = nil
        self.cameraPreview = nil
        self.placeHolderView = nil
    }
    
    //MARK: Camera Processing Methods
    func loadCamera(cameraDelegate: UIViewController) {
        
        self.cameraType = .unspecified
        self.delegate = cameraDelegate
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .denied:
            fallthrough
        case .restricted:
            self.displayAlert("This app need access to use device camera, Please issue access by tapping on settings")
            
        case .authorized:
            self.presentCamera(with: .RearFacingCamera)
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                DispatchQueue.main.async {
                if !granted {
                    self.displayAlert("This app need access to use device camera, Please issue access by tapping on settings")
                    return
                }
                
                self.presentCamera(with: .RearFacingCamera)
                }
            })
        }
    }
    
    
    func presentCamera(with type: CameraType) {
        
        switch type {
        case .RearFacingCamera:
            cameraType = .back
            
        case .FrontFacingCamera:
            self.cameraType = .front
        }
        
        for input in captureSession.inputs {
            self.captureSession.removeInput(input)
        }
        
        for output in captureSession.outputs {
            self.captureSession.removeOutput(output)
        }
        
        if let camera = self.cameraWithPosition(cameraType) {
            
            if (camera.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus)) {
                try! camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
            
            if (camera.isExposureModeSupported(.continuousAutoExposure)) {
                try! camera.lockForConfiguration()
                camera.exposureMode = .continuousAutoExposure
                camera.unlockForConfiguration()
            }
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
                if (self.captureSession.canAddInput(videoDeviceInput)) {
                    self.captureSession.addInput(videoDeviceInput)
                }
            } catch {
                print(error.localizedDescription)
            }
            
            if (self.cameraPreview != nil) {
                self.cameraPreview!.removeFromSuperview()
                self.cameraPreview = nil
            }
            
            let size = UIScreen.main.bounds
            let viewMaxHeight = (size.width > size.height) ? size.width : size.height
            self.placeHolderView = UIView.init(frame: CGRect(x: 0, y: 0, width: viewMaxHeight, height: viewMaxHeight))
            self.placeHolderView!.backgroundColor = UIColor.black
            
            self.cameraPreview = CameraPreview.init(frame: self.delegate.view.frame, session: captureSession)
            
            self.placeHolderView!.addSubview(self.cameraPreview!)
            self.delegate.view.addSubview(self.placeHolderView!)
            
            self.cameraPreview!.hideFlashButton(status: !camera.hasTorch)
            
            if (self.captureSession.canAddOutput(imageOutput)) {
                self.captureSession.addOutput(imageOutput)
                self.imageOutput.isHighResolutionCaptureEnabled = true
            }
            
            self.captureSession.startRunning()
        }
    }
    
    func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        if let device = self.cameraWithPosition(cameraType) {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let deviceDiscovery = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        for device in deviceDiscovery.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    
    //MARK: Camera Control methods
    func capturePressed() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.imageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleCameraPressed() {
        self.captureSession.stopRunning()
        self.cameraPreview!.hideFlashButton(status:(self.cameraType == .front))
        self.presentCamera(with: (self.cameraType == .front) ? .RearFacingCamera : .FrontFacingCamera)
    }
    
    func toggleFlashPressed() {
        
        if (self.cameraWithPosition(cameraType)!.hasTorch == false) {
            return
        }
        
        do {
            try self.cameraWithPosition(cameraType)!.lockForConfiguration()
            if (self.cameraWithPosition(cameraType)!.torchMode == AVCaptureDevice.TorchMode.on) {
                self.cameraWithPosition(cameraType)!.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                try self.cameraWithPosition(cameraType)!.setTorchModeOn(level: 0.5)
            }
            self.cameraWithPosition(cameraType)!.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func dismissPressed() {
        self.removeCameraManager()
    }
    
    //MARK: - AVCapture Photo Capture Delegate methods
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData){
                
                let status = PHPhotoLibrary.authorizationStatus()
                switch status {
                case .authorized:
                    self.imageCaptureComplete(image: image)
                    
                case .denied:
                    fallthrough
                case .restricted :
                    self.displayAlert("This app needs acces to save photos in to photos library.")
                    
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization() { status in
                        if (status != .authorized) {
                            self.displayAlert("Unable to save captured photo, This app needs acces to save photos in to photos library.")
                            return
                        }
                    
                         self.imageCaptureComplete(image: image)
                    }
                }
            }
        }
    }
    
    private func imageCaptureComplete(image: UIImage) {
        let delegate = self.delegate as? CameraDelegate
        if (delegate?.didCompleteImageCapture?(image: image) != nil) {
            delegate!.didCompleteImageCapture!(image: image)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print("unable to save image into photo library")
        }
    }
    
    
    
    //MARK - Alert controller method
    func displayAlert(_ message: String) {
        let alertController = UIAlertController (title: "", message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler:nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.delegate.present(alertController, animated: false, completion: nil)
    }
    
    
    //MARK: Orientation method
    @objc func deviceOrientationChanged() {
        
        var frame = UIScreen.main.bounds
        var orientation : AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            fallthrough
        case .portraitUpsideDown:
            if (frame.size.width > frame.size.height) {
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.height, height: frame.size.width)
            }
            orientation = (UIDevice.current.orientation == .portrait) ? .portrait : .portraitUpsideDown
            
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
            if (frame.size.height > frame.size.width) {
                frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.height, height: frame.size.width)
            }
            
            orientation = (UIDevice.current.orientation == .landscapeRight) ? .landscapeLeft : .landscapeRight
            
        default:
            orientation = .portrait
        }
        
        self.cameraPreview?.frame = frame
        self.cameraPreview?.layoutVideoPreviewLayer(forOrientation: orientation)
    }
}
