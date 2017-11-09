//
//  Classmate.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import Foundation

class Lesson : NSObject, NSCoding {
    
    var lesson_id: Int?
    var subject: String?
    var catalog: String?
    var venueName: String?
    var location: String?
    var class_section: String?
    var credit_unit: Int?
    
    var lecturer: String?
    var lecOffice: String?
    var lecPhone: String?
    var lecAcad: String?
    var lecEmail: String?
    var lecturer_id: Int?
    
    var ldate: String?
    var weekday: String?
    var ldateid: Int?
    
    var major: Int32?
    var minor: Int32?
    
    var start_time: String?
    var end_time: String?
    
    
    var status: Int?
    var recorded_time: String?
    
    override init() {
        lesson_id = 0
        subject = "X"
        catalog = "X"
        lecturer = "Y"
        lecOffice = "X"
        lecPhone = "X"
        ldate = "0/0/0"
        class_section = "P2J3"
        weekday = "0"
        ldateid = 0
        lecAcad = ""
        lecEmail = ""
        major = 0
        minor = 0
        start_time = "00:00"
        end_time = "00:00"
        status = nil
        recorded_time = "00:00"
        lecturer_id = 0
        credit_unit = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as! Int?
        
        subject = aDecoder.decodeObject(forKey: "subject") as! String?
        catalog = aDecoder.decodeObject(forKey: "catalog") as! String?
        
        venueName = aDecoder.decodeObject(forKey: "venueName") as! String?
        location = aDecoder.decodeObject(forKey: "location") as! String?
        class_section = aDecoder.decodeObject(forKey: "class_section") as! String?
        credit_unit = aDecoder.decodeObject(forKey: "credit_unit") as! Int?
        
        lecturer = aDecoder.decodeObject(forKey: "lecturer") as! String?
        lecOffice = aDecoder.decodeObject(forKey: "lecOffice") as! String?
        lecPhone = aDecoder.decodeObject(forKey: "lecPhone") as! String?
        lecEmail = aDecoder.decodeObject(forKey: "lecEmail") as! String?
        lecAcad = aDecoder.decodeObject(forKey: "lecAcad") as! String?
        
        ldateid = aDecoder.decodeObject(forKey: "ldateid") as! Int?
        ldate = aDecoder.decodeObject(forKey: "ldate") as! String?
        weekday = aDecoder.decodeObject(forKey: "weekday") as! String?
        
        major = aDecoder.decodeObject(forKey: "major") as! Int32?
        minor = aDecoder.decodeObject(forKey: "minor") as! Int32?
        
        start_time = aDecoder.decodeObject(forKey: "start_time") as! String?
        end_time = aDecoder.decodeObject(forKey: "end_time") as! String?
        
        status = aDecoder.decodeObject(forKey: "status") as! Int?
        recorded_time = aDecoder.decodeObject(forKey: "recorded_time") as! String?
        lecturer_id = aDecoder.decodeObject(forKey: "lecturer_id") as! Int?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lesson_id, forKey: "lesson_id")
        
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(catalog, forKey: "catalog")
        
        aCoder.encode(venueName, forKey: "venueName")
        
        aCoder.encode(location, forKey: "location")
        aCoder.encode(class_section, forKey: "class_section")
        aCoder.encode(credit_unit, forKey: "credit_unit")
        
        aCoder.encode(lecturer, forKey: "lecturer")
        aCoder.encode(lecOffice, forKey: "lecOffice")
        aCoder.encode(lecPhone, forKey: "lecPhone")
        aCoder.encode(lecAcad, forKey: "lecAcad")
        aCoder.encode(lecEmail, forKey: "lecEmail")
        
        aCoder.encode(ldateid, forKey: "ldateid")
        aCoder.encode(ldate, forKey: "ldate")
        aCoder.encode(weekday, forKey: "weekday")
        
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
        aCoder.encode(start_time, forKey: "start_time")
        aCoder.encode(end_time, forKey: "end_time")
        
        aCoder.encode(status, forKey: "status")
        aCoder.encode(recorded_time, forKey: "recorded_time")
        aCoder.encode(lecturer_id, forKey: "lecturer_id")
        
    }
    
}

class TempStudents : NSObject, NSCoding{
    
    var id : Int?
    
    override init(){
        id = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! Int?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    
}

class Venue{
    
    var id = 0
    var location = ""
    var name = "room"
    var major:Int32 = 0
    var minor:Int32 = 0
}

class History: NSObject, NSCoding{
    
    var name: String?
    var total: Int?
    var absent: Int?
    var present: Int?
    var late:Int?
    
    override init(){
        name = ""
        total = 0
        absent = 0
        present = 0
        late = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String?
        total = aDecoder.decodeObject(forKey: "total") as! Int?
        absent = aDecoder.decodeObject(forKey: "absent") as! Int?
        present = aDecoder.decodeObject(forKey: "present") as! Int?
        late = aDecoder.decodeObject(forKey: "late") as! Int?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(total, forKey: "total")
        aCoder.encode(absent, forKey: "absent")
        aCoder.encode(present, forKey: "present")
        aCoder.encode(late, forKey: "late")
    }
}

class Lecturer: NSObject, NSCoding{
    
    var lesson_id:Int?
    var lec_id:Int?
    var major:Int?
    var minor:Int?
    
    override init(){
        
        lesson_id = 0
        lec_id = 0
        major = 0
        minor = 0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as! Int?
        lec_id = aDecoder.decodeObject(forKey: "lec_id") as! Int?
        major = aDecoder.decodeObject(forKey: "major") as! Int?
        minor =  aDecoder.decodeObject(forKey: "minor") as! Int?
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(lesson_id, forKey: "lesson_id")
        aCoder.encode(lec_id, forKey: "lec_id")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
    }
    
}

class Classmate: NSObject, NSCoding{
    
    var lesson_id:Int?
    var student_id:[Int]?
    var major:[Int]?
    var minor:[Int]?
    
    override init(){
        lesson_id = 0
        student_id = []
        major = []
        minor = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as? Int
        student_id = aDecoder.decodeObject(forKey: "id") as? [Int]
        major = aDecoder.decodeObject(forKey: "major") as? [Int]
        minor = aDecoder.decodeObject(forKey: "minor") as? [Int]
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(lesson_id, forKey: "lesson_id")
        aCoder.encode(student_id, forKey: "id")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
    }
}
