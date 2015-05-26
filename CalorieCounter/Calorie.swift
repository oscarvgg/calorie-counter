//
//  Calorie.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import UIKit

import RealmSwift

public class Calorie: Model {
   
    public dynamic var text: String? = ""
    
    public dynamic var value: Int = 0
    
    public dynamic var remoteOwner: User? = nil
    
    public dynamic var owner: [User] {
        
        return linkingObjects(User.self, forProperty: "calories")
    }
    
    public dynamic var eatenOn: NSDate = NSDate()
    
    public dynamic var createdAt: NSDate = NSDate()
    
    public dynamic var updatedAt: NSDate = NSDate()
    
    
    // MARK: - Realm
    
    public override static func ignoredProperties() -> [String] {
        
        return ["remoteOwner"]
    }
    
    // MARK: - Model
    
    public override class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = Calorie()
        
        model.objectId = raw["objectId"] as? String ?? ""
        
        model.text = raw["text"] as? String ?? ""
        
        model.value = raw["value"] as? Int ?? 0
        

        
        model.createdAt = raw["createdAt"] as? NSDate ?? NSDate()
        model.updatedAt = raw["updatedAt"] as? NSDate ?? NSDate()
        
        return model
    }
    
    
    public override func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        raw["objectId"] = self.objectId
        raw["eatenOn"] = self.eatenOn
        raw["text"] = self.text
        raw["value"] = self.value
        raw["owner"] = self.remoteOwner?.toDictionary()
        
        return raw
    }
    
    
    public override class func tableName() -> String {
        return "Calorie"
    }
    
    
    public override class func tableNameForAssociation(association: String) -> String {
        return "_User"
    }

    public override func save<T : Model>(type: T.Type, completion: (T?, NSError?) -> Void) {
        
        Adapter<T>.save(self as! T, completion: { (savedModel: T?, error: NSError?) -> Void in
            
            if let savedModel = savedModel as? Calorie {
                
                let realm = Realm()
                
                realm.write({ () -> Void in
                    
                    realm.add(savedModel, update: true)
                    
                    if let owner = self.remoteOwner {
                        
                        let user = realm.objectForPrimaryKey(User.self, key: owner.objectId)
                        
                        let oldCalories = user?.calories.filter("objectId = %@", savedModel.objectId)
                        
                        if oldCalories!.count == 0 {
                            
                            user?.calories.append(savedModel)
                        }
                    }
                })
            }
            
            completion(savedModel, error)
        })
    }
}
