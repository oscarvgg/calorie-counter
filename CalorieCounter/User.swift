//
//  User.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import Foundation

import Parse
import RealmSwift

class User: Model {
   
    dynamic var username: String? = ""
    
    dynamic var password: String? = ""
    
    dynamic var email: String? = ""
    
    dynamic var maxDailyCalorieCount: UInt = 0
    
    dynamic var calories = List<Calorie>()
    
    dynamic var createdAt: NSDate = NSDate()
    
    dynamic var updatedAt: NSDate = NSDate()
    
    
    // MARK: - Model
    
    override class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = User()
        
        model.objectId = raw["objectId"] as? String
        
        model.username = raw["username"] as? String
        
        model.maxDailyCalorieCount = UInt((raw["maxDailyCalorieCount"] as! NSString).integerValue)
        
        model.createdAt = raw["createdAt"] as! NSDate
        model.updatedAt = raw["updatedAt"] as! NSDate
        
        return model
    }
    
    
    override func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        raw["objectId"] = self.objectId
        raw["username"] = self.username
        raw["password"] = self.password
        raw["email"] = self.email
        raw["maxDailyCalorieCount"] = String(self.maxDailyCalorieCount)
        raw["createdAt"] = self.createdAt
        raw["updatedAt"] = self.updatedAt
        
        return raw
    }
    
    
    override class func tableName() -> String {
        return "_User"
    }
    
    
    /**
    Gets the current user locally
    
    :returns: returns the current user or nil when no user is logged in
    */
    class func currentUser() -> User? {
        
        if let currentUserId = NSUserDefaults.standardUserDefaults().stringForKey("currentUserId") {
            
            let realm = Realm()
            
            var user = realm.objects(User).filter("objectId = %@", currentUserId)
            
            if user.count > 0 {
                
                return user[0]
            }
        }
        
        return nil
    }
    
    
    // MARK: - Account actions
    
    /**
    Logs in the current user. It involves checkin the values against the server
    and if they are valid, the user is cached locally
    
    :param: username   username of the user to log in
    :param: password   password of the user to log in
    :param: completion completion handler
    */
    class func login(username: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        
        PFUser.logInWithUsernameInBackground(
            username,
            password: password,
            block: { (user: PFUser?, error: NSError?) -> Void in
                
                if let user = user where error == nil {
                    
                    let modelUser = self.modelFromRaw(Adapter.rawToDictionary(user)) as! User
                    
                    NSUserDefaults.standardUserDefaults().setObject(modelUser.objectId, forKey: "currentUserId")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let realm = Realm()
                    realm.write({ () -> Void in
                        
                        realm.add(modelUser, update: true)
                    })
                    
                    completion(user: modelUser, error: nil)
                }
                else {
                    
                    completion(user: nil, error: error)
                }
        })
    }
    
    
    /**
    Logs out the current User
    */
    class func logOutCurrentUser() {
        
        if let currentUserId = NSUserDefaults.standardUserDefaults().stringForKey("currentUserId") {
            
            let realm = Realm()
            
            realm.write { () -> Void in
                
                realm.delete(realm.objects(User).filter("objectId = %@", currentUserId))
            }
            
            NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUserId")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        PFUser.logOut()
    }
    
}
