//
//  ParseAdapter.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 17/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import Parse

public class Adapter<T: Model>: NSObject {
   
    /**
    Transforms a PFObject to Dictionary ob objects compatible with MIModel
    
    :param: raw the raw object (PFObject)
    
    :returns: A Dictionary type from raw object
    */
    public static func rawToDictionary(raw: AnyObject) -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [String: AnyObject]()
        
        if let raw = raw as? PFObject {
            
            if let id = raw.objectId {
                
                dictionary["objectId"] = id
            }
            
            for key in raw.allKeys() {
                
                dictionary[key as! String] = raw.objectForKey(key as! String)!
                
            }
            
            if let createdAt = raw.createdAt, updatedAt = raw.updatedAt {
                
                dictionary["createdAt"] = createdAt
                dictionary["updatedAt"] = updatedAt
            }
        }
        
        return dictionary
    }
    
    
    public static func save(model: Model, completion: (Bool, NSError?) -> Void) {
        
        var rawModel = PFObject(
            withoutDataWithClassName: T.tableName(),
            objectId: model.objectId != "" ? model.objectId : nil)
        
        if rawModel.objectId == PFUser.currentUser()?.objectId {
            
            rawModel = PFUser.currentUser()!
        }
        
        // Build PFObject from model
        for (key, value) in model.toDictionary() {
            
            if key != "objectId" && key != "password" && key != "createdAt" && key != "updatedAt" {
                
                // if value is an object
                if let idValue = value["objectId"] as? String {
                    
                    let association = PFObject(
                        withoutDataWithClassName: T.tableNameForAssociation(key),
                        objectId: idValue)
                    
                    rawModel.setObject(association, forKey: key)
                }
                else {
                    
                    rawModel.setObject(value, forKey: key)
                }
            }
        }
        
        rawModel.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            
            // set the id of the just inserted object to the model
            if model.objectId ==  "" && error == nil {
                model.objectId = rawModel.objectId!
            }
            
            completion(true, error);
        }
    }
    
    
    public static func findWithId(id: String, completion: (T?, NSError?) -> Void) {
        
        var query = PFQuery(className: T.tableName())
        query.whereKey("objectId", equalTo: id)
        
        query.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error: NSError?) -> Void in
            
            if let result = result where error == nil
            {
                var firstResult = result.first as! PFObject
                
                completion(T.modelFromRaw(self.rawToDictionary(firstResult)) as? T, error)
            }
            else {
                completion(nil, error)
            }
            
        }
    }
    
    
    public static func find(query: [String:AnyObject]?, completion: ([T], NSError?) -> Void) {
        
        var parseQuery = PFQuery(className: T.tableName())
        
        if let query = query {
            
            parseQuery = self.buildQuery(query, parseQuery: parseQuery)
        }
        
        parseQuery.findObjectsInBackgroundWithBlock { (result: [AnyObject]?, error: NSError?) -> Void in
            
            if let result = result where error == nil
            {
                var items:[T] = []
                
                for aResult in result {
                    
                    var item = aResult as! PFObject
                    
                    items.append(T.modelFromRaw(self.rawToDictionary(item)) as! T)
                }
                
                completion(items, error)
            }
            else {
                completion([], error)
            }
            
        }
    }
    
    
    public static func delete(model: Model, completion: (Bool, NSError?) -> Void) {
        
        let rawModel: PFObject = PFObject(
            withoutDataWithClassName: T.tableName(),
            objectId: model.objectId)
        
        rawModel.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            
            completion(succeeded, error);
        }
    }
    
    
    public static func buildRaw(id: String) -> AnyObject {
        
        return PFObject(withoutDataWithClassName: T.tableName(), objectId: id) as AnyObject
    }
    
    
    public static func buildRaw(values: [String:AnyObject]) -> AnyObject {
        
        return PFObject(className: T.tableName(), dictionary: values) as AnyObject
    }
    
    
    
    // MARK: - Query
    
    /**
    Transforms a query into a Parse query
    
    :param: query      the query
    :param: parseQuery the parse query
    
    :returns: a Parse query
    */
    public static func buildQuery(query: [String:AnyObject], parseQuery: PFQuery) -> PFQuery {
        
        self.parseWhere(query["where"] as? [String:[String:AnyObject]], parseQuery: parseQuery)
        self.parsePopulate(query["populate"] as? [String], parseQuery: parseQuery)
        
        return parseQuery
    }
    
    
    /**
    Adds the conditions from the where part of a query to a Parse query
    
    :param: whereClause a dictionary with the values in a where clause
    :param: parseQuery  the parse query to add the converted conditions
    
    :returns: a Parse query
    */
    public static func parseWhere(whereClause: [String:[String:AnyObject]]?, parseQuery: PFQuery) -> PFQuery {
        
        if let whereClause = whereClause {
            
            for (property, condition) in whereClause {
                
                for (theOperator, value) in condition {
                    
                    switch theOperator {
                        
                    case "=":
                        parseQuery.whereKey(property, equalTo: value)
                        
                    case ">":
                        parseQuery.whereKey(property, greaterThan: value)
                        
                    case ">=":
                        parseQuery.whereKey(property, greaterThanOrEqualTo: value)
                        
                    case "<":
                        parseQuery.whereKey(property, lessThan: value)
                        
                    case "<=":
                        parseQuery.whereKey(property, lessThanOrEqualTo: value)
                        
                    case "!=":
                        parseQuery.whereKey(property, notEqualTo: value)
                        
                    case "in":
                        parseQuery.whereKey(property, containedIn: value as! [AnyObject])
                        
                    default:
                        break
                        
                    }
                }
            }
        }
        
        return parseQuery
    }
    
    
    /**
    Adds the `include` clause to a parse query
    
    :param: populateClause Array of property names to be populated
    :param: parseQuery     The parse query to add the conditions
    
    :returns: The resulting parse query
    */
    public static func parsePopulate(populateClause: [String]?, parseQuery: PFQuery) -> PFQuery {
        
        if let populateClause = populateClause {
            
            for property in populateClause {
                
                parseQuery.includeKey(property)
            }
        }
        
        return parseQuery
    }
    
}
