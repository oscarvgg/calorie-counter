//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Realm Path
        println("Realm Path: \(Realm.defaultPath)")
        
        // Parse configuration
        Parse.setApplicationId("KZGf53jXvy5VWbqrOsOQSca41W3830eGwib0gYeV", clientKey: "jJdVpFmkqAu7ufMYbTTURU8r8t2mhPiTi6vG4JNl")
        
//        PFUser.enableAutomaticUser()

//        let defaultACL = PFACL()
//        defaultACL.setPublicReadAccess(true)
//        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        // apply styles
        Styler.applyStyle()
        
        // set initial view controller
        let profileStoryboard = UIStoryboard(
            name: "Main",
            bundle: NSBundle.mainBundle())
        
        
        let currentUser = User.currentUser()
        var navigation: UINavigationController? = nil
        
        if let currentUser = currentUser {
            
            navigation = profileStoryboard
                .instantiateInitialViewController() as? UINavigationController
            
            let mainViewController =
            navigation?.viewControllers[0] as? MainTableViewController
            
            mainViewController?.localUser = currentUser
            
            currentUser.getRemoteCalories({ (calories: [Calorie], error: NSError?) -> Void in
                
                
            })
        }
        else {
            
            navigation = profileStoryboard
                .instantiateViewControllerWithIdentifier("logInNavigation") as? UINavigationController
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = navigation
        self.window!.makeKeyAndVisible()

        return true
    }
}
