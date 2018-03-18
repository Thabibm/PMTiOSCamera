//
//  CameraPreview.swift
//  CustomCamera
//
//  Created by Peer Mohamed Thabib on 3/9/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreview: UIView, UIGestureRecognizerDelegate {
    
    //MARK: IBoutlets
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var footerView: UIView!
    @IBOutlet weak private var captureButton: UIButton!
    @IBOutlet weak private var flashButton: UIButton!
    @IBOutlet weak private var toggleButton: UIButton!
    @IBOutlet weak private var contentView:UIView!
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var touchAreaView: UIView?
    private var gridView: GridView?
    private var isTouchViewAnimating = false
    
    //MARK: Init method
    init(frame: CGRect, session: AVCaptureSession) {
        super.init(frame: frame)
        let view = (UINib(nibName: "CameraPreview", bundle: nil).instantiate(withOwner: self, options: nil) as Array).first as! UIView
        view.frame = frame
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer!.frame = self.getPreviewLayerRect()
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        
        self.layer.addSublayer(self.previewLayer!)
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Mark: Preview View appearence methods
    func getPreviewLayerRect() -> CGRect {
        let y = self.headerView.frame.size.height
        let height = self.bounds.size.height - y - footerView.frame.size.height
        return CGRect(x: 0, y: y, width: self.bounds.size.width, height: height)
    }
    
    func layoutVideoPreviewLayer(forOrientation: AVCaptureVideoOrientation) {
        self.layoutIfNeeded()
        previewLayer!.frame = self.getPreviewLayerRect()
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        previewLayer!.connection!.videoOrientation = forOrientation
    }
    
    func hideFlashButton(status: Bool) {
        self.flashButton.isHidden = status
    }
    
    
    //MARK: IBAction methods
    @IBAction func capturePressed(_ sender: Any) {
        self.clearTouchAreaView()
        
        self.alpha = 0.3
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
        
        CameraManager.sharedInstance.capturePressed()
    }
    
    @IBAction func gridPressed(_ sender: Any) {
        
        if (self.gridView != nil) {
            self.gridView?.removeFromSuperview()
            self.gridView = nil
            return
        }
        
        self.gridView = GridView.init(frame: self.getPreviewLayerRect())
        self.gridView!.backgroundColor = UIColor.clear
        self.addSubview(self.gridView!)
    }
    
    @IBAction func toggleFlashPressed(_ sender: Any) {
        self.clearTouchAreaView()
        CameraManager.sharedInstance.toggleFlashPressed()
    }
    
    @IBAction func toggleCameraPressed(_ sender: Any) {
        self.clearTouchAreaView()
        CameraManager.sharedInstance.toggleCameraPressed()
    }
    
    @IBAction func dismissCamerPressed(_ sender: Any) {
        CameraManager.sharedInstance.removeCameraManager()
    }
    
    
    //MARK: Tap Gesture Handler
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let touchPosition = (sender.location(in: sender.view))
        let devicePoint = self.previewLayer?.captureDevicePointConverted(fromLayerPoint: (touchPosition))
        
        let isPointInFrame = self.previewLayer!.frame.contains(touchPosition)
        if (isPointInFrame == true) {
            self.createTouchAreaView(positon: touchPosition)
            
            CameraManager.sharedInstance.focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint!, monitorSubjectAreaChange: true)
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)
            return fabs(velocity.y) > fabs(velocity.x)
        }
        return true
        
    }
    
    
    //MARK: Focus View Calculation methods
    func createTouchAreaView(positon: CGPoint) {
        
        self.clearTouchAreaView()
        
        if (self.isTouchViewAnimating) {
            return
        }
        
        let contentOrgin : CGFloat = 100.0
        let contentSize : CGFloat = 150.0
        
        let positionWithOffset : CGPoint = CGPoint(x: positon.x - contentOrgin, y: positon.y - contentOrgin);
        let sizeWithOffset = CGSize(width: contentSize, height: contentSize)
        self.touchAreaView = UIView()
        self.touchAreaView!.frame = CGRect(origin: positionWithOffset, size: sizeWithOffset)
        self.touchAreaView!.backgroundColor = UIColor.clear
        self.touchAreaView!.layer.borderWidth = 1.5
        self.touchAreaView!.layer.borderColor = UIColor.lightText.cgColor
        self.previewLayer!.addSublayer((self.touchAreaView?.layer)!)
        
        self.touchAreaView!.alpha = 1
        self.isTouchViewAnimating = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.touchAreaView!.frame = CGRect(x: positon.x - contentOrgin/2, y: positon.y - contentOrgin/2, width: contentSize/2, height: contentSize/2)
        }) { (complete) in
            self.isTouchViewAnimating = false
            self.perform(#selector(self.clearTouchAreaView), with: nil, afterDelay: 3.5)
        }
    }
    
    @objc func clearTouchAreaView() {
        if (self.isTouchViewAnimating == false) {
            self.touchAreaView?.removeFromSuperview()
            self.touchAreaView = nil
        }
    }
}
