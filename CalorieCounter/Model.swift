//
//  Model.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import Foundation

import RealmSwift

public class Model: Object {
   
    public dynamic var objectId: String = ""
    
    
    // MARK: - Realm
    
    override public static func primaryKey() -> String? {
        return "objectId"
    }
    
    
    // MARK: - Model
    
    public class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = Model()
        
        model.objectId = raw["objectId"] as! String
        
        return model
    }
    
    
    public func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        raw["objectId"] = self.objectId
        
        return raw
    }
    
    
    public class func tableName() -> String {
        return ""
    }
    
    
    public class func tableNameForAssociation(association: String) -> String {
        return ""
    }
    
    
    public func save<T:Model>(type: T.Type, completion: (Bool, NSError?) -> Void) {
        
        Adapter<T>.save(self, completion: { (succeeded : Bool, error: NSError?) -> Void in
            
            if succeeded {
                
                Realm().write({ () -> Void in
                    
                    Realm().add(self, update: true)
                })
            }
            
            completion(succeeded, error)
        })
    }
    
    
    public func delete<T:Model>(type: T.Type, completion: (Bool, NSError?) -> Void) {
        
        let me = Realm().objects(T).filter("objectId == %@", self.objectId)
        
        Adapter<T>.delete(self, completion: { (succeeded: Bool, error: NSError?) -> Void in
            
            if !succeeded {
                
                return completion(succeeded, error)
            }
            
            let realm = Realm()
            
            // remove me from local database
            realm.write({ () -> Void in
                
                let me = Realm().objects(T).filter("objectId == %@", self.objectId)
                
                realm.delete(me)
            })
            
            completion(succeeded, error)
        })
    }
}
