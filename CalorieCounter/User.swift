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

public class User: Model {
   
    public dynamic var username: String? = ""
    
    public dynamic var password: String? = ""
    
    public dynamic var email: String? = ""
    
    public dynamic var maxDailyCalorieCount: Int = 2000
    
    public dynamic var calories = List<Calorie>()
    
    public dynamic var createdAt: NSDate = NSDate()
    
    public dynamic var updatedAt: NSDate = NSDate()
    
    
    // MARK: - Model
    
    public override class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
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
    
    
    public override func toDictionary() -> [String: AnyObject] {
        
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
    
    
    public override class func tableName() -> String {
        return "_User"
    }
    
    
    /**
    Gets the current user locally
    
    :returns: returns the current user or nil when no user is logged in
    */
    public class func currentUser() -> User? {
        
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
    public class func login(username: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        
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
    public class func signUp(user: User, completion: (User?, NSError?) -> Void) {
        
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
    public class func logOutCurrentUser() {
        
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
    
    
    // MARK: - Calories
    
    public func todaysEntries() -> [Calorie] {
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = calendar?.components(
            NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
            fromDate: NSDate())
        
        // today at 10AM
        components?.hour = 0
        components?.minute = 0
        components?.second = 0
        
        let todayStart = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        
        components?.hour = 23
        components?.minute = 59
        components?.second = 59
        
        let todayEnd = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        
        return self.caloriesInRange(
            (todayStart!, todayEnd!),
            timeRange: (0, 0, 23, 59))
    }
    
    
    public func caloriesInRange(dateRange: (from: NSDate, to: NSDate), timeRange: (fromHour: Int, fromMinute: Int, toHour: Int, toMinute: Int)) -> [Calorie] {
        
        // current calendar
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        
        // build from date
        let fromComponents = calendar?.components(
            NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
            fromDate: dateRange.from)
        
        fromComponents?.hour = timeRange.fromHour
        fromComponents?.minute = timeRange.fromMinute
        fromComponents?.second = 0
        
        let from = calendar?.dateByAddingComponents(
            fromComponents!,
            toDate: dateRange.from,
            options: NSCalendarOptions.allZeros)
        
        // build to date
        let toComponents = calendar?.components(
            NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
            fromDate: dateRange.to)
        
        toComponents?.hour = timeRange.toHour
        toComponents?.minute = timeRange.toMinute
        toComponents?.second = 0
        
        let to = calendar?.dateByAddingComponents(
            toComponents!,
            toDate: dateRange.to,
            options: NSCalendarOptions.allZeros)
        
        // get all entries in date range
        let calories = self.calories.filter("eatenOn >= %@ AND eatenOn <= %@",
            from!,
            to!)
        .sorted("eatenOn", ascending: true)
        
        // calculates number of minutes in each time interval
        let fromMinutesSinceDate = (timeRange.fromHour * 60) + timeRange.fromMinute
        let toMinutesSinceDate = (timeRange.toHour * 60) + timeRange.toMinute
        
        // where to store results
        var finalResult: [Calorie] = []
        
        for calorie in calories {
            
            // calculates number of minutes in the eaten date
            let dateEatenComponents = calendar?.components(
                NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute,
                fromDate: calorie.eatenOn)
            
            let hour = dateEatenComponents?.hour
            let minute = dateEatenComponents?.minute
            
            // is eaten date in time interval?
            if let hour = hour, minute = minute {
                
                let minutesSinceEatenDate = (hour * 60) + minute
                
                if minutesSinceEatenDate >= fromMinutesSinceDate &&
                    minutesSinceEatenDate <= toMinutesSinceDate {
                        
                        finalResult.append(calorie)
                }
            }
            
        }
        
        return finalResult
    }
    
    
    /**
    Gets all the calories entries from the server and updates the local records
    
    :param: completion completion handler
    */
    public func getRemoteCalories(completion: ([Calorie], NSError?) -> Void) {
        
        let me: AnyObject = Adapter<User>.buildRaw(self.objectId)
        
        Adapter<Calorie>.find(
            ["where":
                ["owner": ["=": me]],
                "populate": ["owner"]],
            completion: { (calories: [Calorie], error: NSError?) -> Void in
                
                
                if calories.count > 0 && error == nil {
                    
                    let realm = Realm()
                    
                    realm.write({ [unowned self] () -> Void in
                        
                        for newCalorie in calories {
                            
                            realm.add(newCalorie, update: true)
                            
                            let oldCalorie = self.calories.filter("objectId = %@", newCalorie.objectId)
                            
                            if oldCalorie.count == 0 {
                                
                                self.calories.append(newCalorie)
                            }
                        }
                    })
                    
                    completion(calories, nil)
                }
                else {
                    
                    completion([], error)
                }
        })
    }
}
