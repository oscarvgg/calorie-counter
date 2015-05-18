//
//  Model.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import RealmSwift

class Model: Object {
   
    dynamic var objectId: String? = ""
    
    
    // MARK: - Realm
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
    
    
    // MARK: - Model
    
    class func modelFromRaw(raw: [String: AnyObject]) -> Model {
        
        let model = Model()
        
        model.objectId = raw["objectId"] as? String
        
        return model
    }
    
    
    func toDictionary() -> [String: AnyObject] {
        
        var raw: [String: AnyObject] = [:]
        
        raw["objectId"] = self.objectId
        
        return raw
    }
    
    
    class func tableName() -> String {
        return ""
    }
    
    
    class func tableNameForAssociation(association: String) -> String {
        return ""
    }
}
