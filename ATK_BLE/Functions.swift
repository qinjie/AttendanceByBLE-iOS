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
                    }
                    
                    if let lecturer = json["lecturers"] as? [String:Any]{
                        
                        newLesson.lecturer = lecturer["name"] as? String
                        newLesson.lecAcad = lecturer["acad"] as? String
                        newLesson.lecEmail = lecturer["email"] as? String
                        newLesson.lecOffice = lecturer["office"] as? String
                        newLesson.lecPhone = lecturer["phone"] as? String
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
                NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.timetablePath)
                print("Done loading timetable")
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
                    history.status = json["status"] as? Int
                    let time = Format.Format(date: Format.Format(string: (json["recorded_time"] as? String)!, format: "HH:mm:ss"), format: "HH:mm")
                    let lesson = (json["lesson_date"] as? [String:AnyObject])!
                    history.lesson_id = lesson["lesson_id"] as? Int
                    history.ldate = lesson["ldate"] as? String
                    history.recorded_time = time
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
        let token = UserDefaults.standard.string(forKey: "token")
        let header:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        let parameter:Parameters = ["lesson_date_id":GlobalData.currentLesson.ldateid!]
        print(GlobalData.currentLesson.ldateid!)
        
        Alamofire.request(Constant.URLcheckAttandance,method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response:DataResponse) in
            if let JSON = response.result.value as? Int{
                print("JSON below")
                print(JSON)
                if(JSON >= 0) {
                    print("/////////taken already")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taken"), object: nil)
                }
                else {
                    print("JSON not > or = 0")
                }
                
            }
                //check if JSON is nil
            else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notTaken"), object: nil)
            }
        })
    }
}


class checkLesson{
    
    static func checkCurrentLesson() -> Bool{
        let today = Date()
        GlobalData.currentDateStr = Format.Format(date: today, format: "yyyy-MM-dd")
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        //check if today have lessons
        if GlobalData.today.count > 0 {
            let currentTimeStr = Format.Format(date: today, format: "HH:mm:ss")
            let currentLesson = GlobalData.today.first(where: {$0.start_time!<=currentTimeStr && $0.end_time!>=currentTimeStr})
            //check current have lessons?
            if currentLesson != nil {
                GlobalData.currentLesson = currentLesson!
                return true
            }else{
                return false
            }
        }else{
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
            let totalSecond = hour*3600 + minute*60 - 300
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


