//
//  UserModelTests.swift
//  CalorieCounter
//
//  Created by Oscar Vicente González Greco on 25/5/15.
//  Copyright (c) 2015 Oscarvgg. All rights reserved.
//

import Calorie_Counter

import UIKit
import XCTest

import RealmSwift

class UserModelTests: XCTestCase {

    override func setUp() {
        
        super.setUp()
        
        // current calendar
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = calendar?.components(
            NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
            fromDate: NSDate())
        
        // today at 10AM
        components?.hour = 10
        components?.minute = 0
        components?.second = 0
        
        let todayAt10AM = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        // today at 12M
        components?.hour = 12
        components?.minute = 30
        components?.second = 0
        
        let todayAt12M = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        // today at 4PM
        components?.hour = 16
        components?.minute = 5
        components?.second = 0
        
        let todayAt4PM = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        // today at 6PM
        components?.hour = 18
        components?.minute = 45
        components?.second = 0
        
        let todayAt6PM = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        
        // Yesterday at 8AM
        components?.hour = 8 - 24
        components?.minute = 0
        components?.second = 0
        
        let yesterdayAt8AM = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        
        let entry1 = Calorie()
        entry1.objectId = "10AM"
        entry1.eatenOn = todayAt10AM!
        
        let entry2 = Calorie()
        entry2.objectId = "12AM"
        entry2.eatenOn = todayAt12M!
        
        let entry3 = Calorie()
        entry3.objectId = "4PM"
        entry3.eatenOn = todayAt4PM!
        
        let entry4 = Calorie()
        entry4.objectId = "6PM"
        entry4.eatenOn = todayAt6PM!
        
        let entry5 = Calorie()
        entry5.objectId = "8AM"
        entry5.eatenOn = yesterdayAt8AM!
        
        let user = User()
        user.objectId = "user"
        
        user.calories.extend([entry1, entry2, entry3, entry4, entry5])
        
        // Add to local databse
        
        let realm = Realm()
        
        realm.write { () -> Void in
            
            realm.add(user, update: true)
        }
    }
    
    override func tearDown() {
        
        // remove from local database
        
        let realm = Realm()
        
        let entries = realm.objects(Calorie.self).filter("objectId IN %@",
            ["10AM", "12AM", "4PM", "6PM", "8AM"])
        
        let user = realm.objects(User.self).filter("objectId == %@", "user")
        
        realm.write { () -> Void in
            
            realm.delete(user)
            realm.delete(entries)
        }
        
        super.tearDown()
    }

    func testRetreavingTodaysEntries() {
        
        let realm = Realm()
        
        let user = realm.objects(User.self).filter("objectId == %@", "user")
        
        let todaysEntries = user[0].todaysEntries()
        
        XCTAssertEqual(todaysEntries.count, 4, "number of entries for today do not match")
    }
    
    
    func testRetreavingRangedEntries() {
        
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        
        // build from date
        let components = calendar?.components(
            NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond,
            fromDate: NSDate())
        
        components?.hour = 6 - 24
        components?.minute = 50
        components?.second = 0
        
        let from = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        components?.hour = 16
        components?.minute = 45
        components?.second = 0
        
        let to = calendar?.dateByAddingComponents(
            components!,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)
        
        
        let realm = Realm()
        
        let user = realm.objects(User.self).filter("objectId == %@", "user")
        
        let todaysEntries = user[0].caloriesInRange(
            (from: from!, to: to!),
            timeRange: (fromHour: 11, fromMinute: 35, toHour: 18, toMinute: 30))
        
        XCTAssertEqual(todaysEntries.count, 2, "number of entries for range do not match")
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
