//
//  GridView.swift
//  CustomCamera
//
//  Created by Peer Mohamed Thabib on 3/12/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    private var viewSize : CGSize?
    
    override init(frame: CGRect) {
        self.viewSize = frame.size
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let gridMatrixSize = 2
        let gridLineWidth : CGFloat = 0.5
        let gridColor = UIColor(white: 75.0, alpha: 0.5)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(gridLineWidth)
            context.setStrokeColor(gridColor.cgColor)
            
            let width = self.viewSize!.width
            let height = self.viewSize!.height
            
            let columnWidth = (width) / CGFloat(gridMatrixSize + 1)
            let rowHeight = (height) / CGFloat(gridMatrixSize + 1)
            
            for i in 1...gridMatrixSize {
                
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                
                startPoint.x = columnWidth * CGFloat(i)
                startPoint.y = 0
                
                endPoint.x = columnWidth * CGFloat(i)
                endPoint.y = height
                
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }
            
            
            for j in 1...gridMatrixSize {
                
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                
                startPoint.x = 0
                startPoint.y = rowHeight * CGFloat(j)
                
                endPoint.x = width
                endPoint.y = rowHeight * CGFloat(j)
                
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }
        }
    }
}
