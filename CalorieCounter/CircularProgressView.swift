//
//  CircularProgressView.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 27/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {

    
    @IBInspectable
    var progress: Int = 60 {
        
        didSet {
            
            self.updatePath()
        }
    }
    
    @IBInspectable
    var totalValue: Int = 100 {
        
        didSet {
            
            self.updatePath()
        }
    }
    
    @IBInspectable
    var pathWith: CGFloat = 6
    
    @IBInspectable
    var pathColor: UIColor = UIColor.greenColor()
    
    @IBInspectable
    var exceededPathColor: UIColor = UIColor.redColor()
    
    private var pathLayer: CAShapeLayer!
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if self.pathLayer != nil {
            
            updatePath()
            
            return
        }
        
        // Add background path
        let backgroundPath = CAShapeLayer()
        let path = UIBezierPath(
            arcCenter: CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2),
            radius: CGFloat((self.frame.size.width - self.pathWith) / 2),
            startAngle: CGFloat(0),
            endAngle: CGFloat(2 * M_PI),
            clockwise: true)
        
        backgroundPath.fillColor = UIColor.clearColor().CGColor
        backgroundPath.path = path.CGPath
        backgroundPath.strokeColor = UIColor.lightGrayColor().CGColor
        backgroundPath.lineWidth = self.pathWith
        
        self.layer.addSublayer(backgroundPath)
        
        // Add progress path
        self.pathLayer = CAShapeLayer()
        self.pathLayer.fillColor = UIColor.clearColor().CGColor
        
        self.layer.addSublayer(self.pathLayer)
        
         var transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, CGFloat(-M_PI_2), 0, 0, 1)
        self.layer.transform = transform
        
        self.updatePath()
    }
    
    
    func updatePath() {
        
        if self.pathLayer == nil {
            
            return
        }
        
        var color: UIColor!
        
        if self.progress > self.totalValue {
            
            color = self.exceededPathColor
        }
        else {
            
            color = self.pathColor
        }
        
        let path = UIBezierPath(
            arcCenter: CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2),
            radius: CGFloat((self.frame.size.width - self.pathWith) / 2),
            startAngle: CGFloat(0),
            endAngle: CGFloat(2 * M_PI * Double(self.progress) / Double(self.totalValue)),
            clockwise: true)
        
        self.pathLayer.path = path.CGPath
        self.pathLayer.strokeColor = color.CGColor
        self.pathLayer.lineWidth = self.pathWith
    }

}
