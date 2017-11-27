//
//  alamofire.swift
//  ATK_BLE
//
//  Created by KyawLin on 7/14/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications

struct alamofire{
    
    static func loadSemesterTimetable(){
        let token = UserDefaults.standard.string(forKey: "token")
        //Load semester timetable
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        
        Alamofire.request(Constant.URLSemesterTimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                GlobalData.semesterTimetable.removeAll()
                
                for json in JSON{
                    let newLesson = Lesson()
                    newLesson.lesson_id = json["id"] as? Int
                    newLesson.subject = json["subject_area"] as? String
                    newLesson.catalog = json["catalog_number"] as? String
                    newLesson.class_section = json["class_section"] as? String
                    newLesson.location = json["facility"] as? String
                    newLesson.weekday   = json["weekday"] as? String
                    newLesson.start_time = json["start_time"] as? String
                    newLesson.end_time = json["end_time"] as? String
                    newLesson.credit_unit = Int((json["credit_unit"] as? String)!)
                    
                    if let lecturer = json["lecturers"] as? [String: Any]{
                        newLesson.lecturer = lecturer["name"] as? String
                        newLesson.lecAcad = lecturer["acad"] as? String
                        newLesson.lecEmail = lecturer["email"] as? String
                        newLesson.lecPhone = lecturer["phone"] as? String
                        newLesson.lecOffice = lecturer["office"] as? String
                        newLesson.lecturer_id = lecturer["id"] as? Int
                    }
                    
                    GlobalData.semesterTimetable.append(newLesson)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.semesterTimetable, toFile: filePath.semesterTimetablePath)
                log.info("done loading semester timetable")
            }
        }
    }
    
    static func loadTimetable(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        //Load timetable, lecturer and lesson...
        let headersTimetable:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        
        Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersTimetable).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                
                GlobalData.timetable.removeAll()
                
                for json in JSON{
                    let newLesson = Lesson()
                    
                    if let lesson = json["lesson"] as? [String:Any]{
                        newLesson.lesson_id = lesson["id"] as? Int
                        newLesson.catalog = lesson["catalog_number"] as? String
                        newLesson.subject = lesson["subject_area"] as? String
                        newLesson.start_time = lesson["start_time"] as? String
                        newLesson.end_time = lesson["end_time"] as? String
                        newLesson.weekday = lesson["weekday"] as? String
                        newLesson.class_section = lesson["class_section"] as? String
                        newLesson.credit_unit =  Int((lesson["credit_unit"] as? String)!)
                    }
                    
                    if let lecturer = json["lecturers"] as? [String:Any]{
                        
                        newLesson.lecturer = lecturer["name"] as? String
                        newLesson.lecAcad = lecturer["acad"] as? String
                        newLesson.lecEmail = lecturer["email"] as? String
                        newLesson.lecOffice = lecturer["office"] as? String
                        newLesson.lecPhone = lecturer["phone"] as? String
                        newLesson.lecturer_id = lecturer["id"] as? Int
                        
                        if let beacon = lecturer["beacon"] as? [String:Any]{
                            
                            let newLecturer = Lecturer()
                            newLecturer.lec_id = lecturer["id"] as? Int
                            newLecturer.major = beacon["major"] as? Int
                            newLecturer.minor = beacon["minor"] as? Int
                            GlobalData.lecturers.append(newLecturer)
                            
                        }
                    }
                    
                    if let lesson_date = json["lesson_date"] as? [String:Any]{
                        
                        newLesson.ldateid = lesson_date["id"] as? Int
                        newLesson.ldate = lesson_date["ldate"] as? String
                    }
                    
                    if let venue = json["venue"] as? [String:Any]{
                        
                        newLesson.major = venue["major"] as? Int32
                        newLesson.minor = venue["minor"] as? Int32
                        newLesson.venueName = venue["name"] as? String
                        newLesson.location = venue["location"] as? String
                    }
                    GlobalData.timetable.append(newLesson)
                }
                //Write timetable to the local directory
                NSKeyedArchiver.archiveRootObject(GlobalData.lecturers, toFile: filePath.lecturerPath)
                NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.timetablePath)
                log.info("Done loading timetable")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "done loading timetable"), object: nil)
            }
            
        }
    }
    
    static func loadOverallHistory(){
        
        let token = UserDefaults.standard.string(forKey: "token")!
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token
        ]
        Alamofire.request(Constant.URLhistory, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            GlobalData.history.removeAll()
            if let JSON = response.result.value as? [AnyObject]{
                for json in JSON{
                    let newHistory = History()
                    newHistory.name = json["lesson_name"] as? String
                    newHistory.absent = json["absented"] as? Int
                    newHistory.present = json["presented"] as? Int
                    newHistory.total = json["total"] as? Int
                    newHistory.late = json["late"] as? Int
                    GlobalData.history.append(newHistory)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.history, toFile: filePath.historyPath)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "done loading historyOverall"), object: nil)
            }
        }
    }
    
    static func loadHistory(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        Alamofire.request(Constant.URLattendance, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
            if let JSON = response.result.value as? [[String:Any]]{
                GlobalData.attendance.removeAll()
                for json in JSON{
                    let history = Lesson()
                    history.ldateid = json["lesson_date_id"] as? Int
                    history.lecturer_id = json["lecturer_id"] as? Int
                    let status = json["status"] as! Int
                    if status > 0 {
                        history.status = status/60
                    }else{
                        history.status = status
                    }
                    if let lesson = json["lesson_date"] as? [String:AnyObject]{
                        history.lesson_id = lesson["lesson_id"] as? Int
                        history.ldate = lesson["ldate"] as? String
                    }
                    if let lesson = json["lesson"] as? [String:AnyObject]{
                        history.subject = lesson["subject_area"] as? String
                        history.catalog = lesson["catalog_number"] as? String
                        history.class_section = lesson["class_section"] as? String
                        history.location = lesson["facility"] as? String
                        history.start_time = lesson["start_time"] as? String
                        history.end_time = lesson["end_time"] as? String
                        history.weekday = lesson["weekday"] as? String
                    }
                    
                    GlobalData.attendance.append(history)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.attendance, toFile: filePath.historyDTPath)
                HistoryBrain.arrangeHistory()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "done loading history"), object: nil)
            }
        })
        
    }
    
}

struct checkAttendance{
    
    static func checkAttendance() {
        if GlobalData.currentLesson.ldateid != nil{
            let token = UserDefaults.standard.string(forKey: "token")
            let header:HTTPHeaders = [
                "Authorization" : "Bearer " + token!
            ]
            let parameter:Parameters = ["lesson_date_id":GlobalData.currentLesson.ldateid!]
            log.info("Lesson Date Id : \(GlobalData.currentLesson.ldateid!)")
            
            Alamofire.request(Constant.URLcheckAttandance,method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response:DataResponse) in
                if let JSON = response.result.value as? Int{
                    log.info("JSON returned \(JSON)")
                    if(JSON >= 0) {
                        log.info("/////////taken already")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taken"), object: nil)
                    }
                    else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notTaken"), object: nil)
                    }
                    
                }
            })
        }
    }
}


class checkLesson{
    
    static func checkCurrentLesson() -> Bool{
        var today = Date()
        GlobalData.currentDateStr = Format.Format(date: today, format: "yyyy-MM-dd")
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        //check if today have lessons
        if GlobalData.today.count > 0 {
            today.addTimeInterval(600)
            let currentTimeStr = Format.Format(date: today, format: "HH:mm:ss")
            let currentLesson = GlobalData.today.first(where: {$0.start_time!<=currentTimeStr && $0.end_time!>=currentTimeStr})
            //check current have lessons?
            if currentLesson != nil {
                GlobalData.currentLesson = currentLesson!
                return true
            }else{
                GlobalData.currentLesson.ldateid = nil
                return false
            }
        }else{
            GlobalData.currentLesson.ldateid = nil
            return false
        }
    }
    
    static func checkNextLesson() -> Bool{
        let today = Date()
        let currentTimeStr = Format.Format(date: today, format: "HH:mm:ss")
        if let nLesson = GlobalData.today.first(where: {$0.start_time!>currentTimeStr}){
            //Estimate the next lesson time
            let time = nLesson.start_time?.components(separatedBy: ":")
            var hour:Int!
            var minute:Int!
            hour = Int((time?[0])!)
            minute = Int((time?[1])!)
            let totalSecond = hour*3600 + minute*60 - 600
            let hr = totalSecond/3600
            let min = (totalSecond%3600)/60
            GlobalData.nextLessonTime = "not yet time \ntry again after \(hr):\(min)"
            GlobalData.nextLesson = nLesson
            return true
        }else{
            return false
        }
    }
}

struct notification{
    static func notiContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        return content
    }
    static func addNotification(trigger: UNNotificationTrigger?, content:UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {
            (error) in
            if error != nil {
                print("error adding notigicaion: \(error!.localizedDescription)")
            }
        }
    }
    
}

struct Format{
    static func Format(date: Date, format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func Format(string: String, format: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)!
    }
}


