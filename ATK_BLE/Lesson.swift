//
//  Lesson.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation

class Lesson: NSObject, NSCoding{
    
   // var detect: Bool = true
    var lesson_id: Int?
    
    var name: String?
    var venueName: String?
    
    var ldate: String?
    var weekday: String?
    var ldateid: Int?
    
    var major: Int32?
    var minor: Int32?
    
//    var photopath: String = ""
//    var resident_id: Int = 0
    
    var start_time: String?
    
    var end_time: String?

//    var status: Bool = true
//    var uuid: String = ""
    
   // var venue: Venue = Venue()
    
    override init(){
        lesson_id = 0
        name = "X"
        ldate = "0/0/0"
        weekday = "0"
        ldateid = 0
        major = 0
        minor = 0
        start_time = "00:00"
        end_time = "00:00"
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as! Int?
        
     //   status = aDecoder.decodeObject(forKey: "status") as? Bool ?? true
        
        name = aDecoder.decodeObject(forKey: "name") as! String?
        venueName = aDecoder.decodeObject(forKey: "venueName") as! String?
        
        ldateid = aDecoder.decodeObject(forKey: "ldateid") as! Int?
        ldate = aDecoder.decodeObject(forKey: "ldate") as! String?
        weekday = aDecoder.decodeObject(forKey: "weekday") as! String?
        
        major = aDecoder.decodeObject(forKey: "major") as! Int32?
        minor = aDecoder.decodeObject(forKey: "minor") as! Int32?
       
        start_time = aDecoder.decodeObject(forKey: "start_time") as! String?
        end_time = aDecoder.decodeObject(forKey: "end_time") as! String?
        
//
//        weekday = aDecoder.decodeObject(forKey: "weekday") as? String ?? ""
//        lat = aDecoder.decodeObject(forKey: "lat") as? String ?? ""
//        long = aDecoder.decodeObject(forKey: "long") as? String ?? ""
//        isRelative = aDecoder.decodeObject(forKey: "isRelative") as? Bool ?? false
//        status = aDecoder.decodeObject(forKey: "status") as? Bool ?? true
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(lesson_id, forKey: "lesson_id")
        
        aCoder.encode(name, forKey: "name")
        aCoder.encode(venueName, forKey: "venueName")
        
        aCoder.encode(ldateid, forKey: "ldateid")
        aCoder.encode(ldate, forKey: "ldate")
        aCoder.encode(weekday, forKey: "weekday")
        
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
       
        aCoder.encode(start_time, forKey: "start_time")
        aCoder.encode(end_time, forKey: "end_time")
      
    }

    
}

class Venue{
    
    var id: Int = 0
    var location: String = ""
    var name: String = "room"
    var major: Int32 = 0
    var minor: Int32 = 0
    
}

class BeaconUser{
    
    var id: Int = 0
    var major: Int = 0
    var minor: Int = 0
    
}

