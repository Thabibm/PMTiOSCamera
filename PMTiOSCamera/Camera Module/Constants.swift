//
//  Constants.swift
//  CustomCamera
//
//  Created by Peer Mohamed Thabib on 3/10/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation
import UIKit

enum CameraType : Int {
    case RearFacingCamera = 1,
    FrontFacingCamera = 2
}


@objc protocol CameraDelegate {
    @objc optional
    func didCompleteImageCapture(image: UIImage)
}
