//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Parse configuration
        Parse.setApplicationId("KZGf53jXvy5VWbqrOsOQSca41W3830eGwib0gYeV", clientKey: "jJdVpFmkqAu7ufMYbTTURU8r8t2mhPiTi6vG4JNl")
        
        PFUser.enableAutomaticUser()

        let defaultACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        
        // apply styles
        Styler.applyStyle()

        return true
    }
}
