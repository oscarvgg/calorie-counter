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
    
    dynamic var maxDailyCalorieCount: Int = 2000
    
    dynamic var calories = List<Calorie>()
    
    dynamic var createdAt: NSDate = NSDate()
    
    dynamic var updatedAt: NSDate = NSDate()
    
    
    // MARK: - Model
    
    override class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = User()
        
        model.objectId = raw["objectId"] as? String ?? ""
        
        model.username = raw["username"] as? String ?? ""
        
        model.maxDailyCalorieCount = raw["maxDailyCalorieCount"] as? Int ?? 2000
        
//        let calories = Realm().objects(Calorie.self)
//        let userCalories = calories.filter("owner = %@", model)
//        
//        if userCalories.count > 0 {
//            
//            model.calories.extend(userCalories)
//        }
        
        model.createdAt = raw["createdAt"] as? NSDate ?? NSDate()
        model.updatedAt = raw["updatedAt"] as? NSDate ?? NSDate()
        
        return model
    }
    
    
    override func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        if self.objectId != "" {
            
            raw["objectId"] = self.objectId
        }

        raw["username"] = self.username
//        raw["password"] = self.password
        raw["email"] = self.email
        raw["maxDailyCalorieCount"] = self.maxDailyCalorieCount
        
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
                    
                    Adapter<User>.findWithId(user.objectId!, completion: { (user: User?, error: NSError?) -> Void in
                    
                        if let user = user where error == nil {
                            
                            NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: "currentUserId")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            let realm = Realm()
                            realm.write({ () -> Void in
                                
                                realm.add(user, update: true)
                            })
                            
                            completion(user: user, error: nil)
                        }
                    })
                }
                else {
                    
                    completion(user: nil, error: error)
                }
        })
    }
    
    
    /**
    Registers a user to the server and saves it's data to the local cache
    
    :param: user       the user model to register
    :param: completion a completion handler with the registered user or error
    */
    class func signUp(user: User, completion: (User?, NSError?) -> Void) {
        
        let rawUser = Adapter<User>.buildRaw(user.toDictionary()) as! PFUser
        rawUser.password = user.password
        rawUser.username = user.username
        rawUser.email = user.email
        
        rawUser.signUpInBackgroundWithBlock({ (succeded: Bool, error: NSError?) -> Void in
            
            if error == nil {
                
                user.objectId = rawUser.objectId!
                
                NSUserDefaults.standardUserDefaults().setObject(user.objectId, forKey: "currentUserId")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let realm = Realm()
                
                realm.write({ () -> Void in
                    
                    realm.add(user, update: true)
                })
                
                completion(user, nil)
            }
            else {
                
                completion(nil, error)
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
