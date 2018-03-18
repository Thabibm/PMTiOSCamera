//
//  ViewController.swift
//  PMTiOSCamera
//
//  Created by Peer Mohamed Thabib on 3/18/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CameraDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CameraManager.sharedInstance.loadCamera(cameraDelegate: self)
    }
    
    func didCompleteImageCapture(image: UIImage) {
        // Process the captured image
    }

}

