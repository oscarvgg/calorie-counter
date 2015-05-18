//
//  Calorie.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

class Calorie: Model {
   
    dynamic var text: String? = ""
    
    dynamic var value: UInt = 0
    
    dynamic var owner: [User] {
            
            return linkingObjects(User.self, forProperty: "calories")
    }
    
    dynamic var createdAt: NSDate = NSDate()
    
    dynamic var updatedAt: NSDate = NSDate()
    
    
    // MARK: - Model
    
    override class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = Calorie()
        
        model.objectId = raw["objectId"] as? String
        
        model.text = raw["text"] as? String
        
        model.value = UInt((raw["value"] as! NSString).integerValue)
        
        model.createdAt = raw["createdAt"] as! NSDate
        model.updatedAt = raw["updatedAt"] as! NSDate
        
        return model
    }
    
    
    override func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        raw["objectId"] = self.objectId
        raw["text"] = self.text
        raw["value"] = String(self.value)
        raw["createdAt"] = self.createdAt
        raw["updatedAt"] = self.updatedAt
        
        return raw
    }
    
    
    override class func tableName() -> String {
        return "_User"
    }
}
