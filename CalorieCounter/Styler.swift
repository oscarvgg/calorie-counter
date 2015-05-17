//
//  Styler.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

class Styler: NSObject {
   
    class func applyStyle() {
        
        // general color
        UIWindow.appearance().tintColor = self.appGenericColor()
        
        self.styleNavigationController()
        self.styleBarButtonItem()
    }
    
    
    class func appGenericColor() -> UIColor {
        
        return UIColor(
            red: 0.937255,
            green: 0.258824,
            blue: 0.341176,
            alpha: 1)
    }
    
    
    private class func styleNavigationController() {
        
        
        // Style background colour
        UINavigationBar.appearance().barTintColor = self.appGenericColor()
        UINavigationBar.appearance().translucent = false
        
        
        // Style bar items colour
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        // Remove border line
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            forBarPosition: .Any,
            barMetrics: .Default)
        
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    
    class func styleBarButtonItem() {
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
    }
    
}
