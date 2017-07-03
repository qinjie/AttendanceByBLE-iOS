//
//  Items.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.//


import CoreLocation
import Foundation


struct Constant{
    static let baseURL = "http://188.166.247.154/atk-ble/"
    // static let URLlogin = baseURL + "api/web/index.php/v1/user/login"
    static let URLlogout = baseURL + "api/web/index.php/v1/user/logout"
    static let URLstudentlogin = baseURL + "api/web/index.php/v1/student/login"
    static let URLtimetable = baseURL + "api/web/index.php/v1/timetable?expand=lesson,lesson_date,lecturers,venue"
    static let URLlessonUUID = baseURL + "api/web/index.php/v1/beacon-lesson/uuid"

    static let URLcurrentLesson = baseURL + "api/web/index.php/v1/timetable/time"
    static let URLhistory = baseURL + "api/web/index.php/v1/student/history"
    
    static let URLclassmate = baseURL + "api/web/index.php/v1/timetable/get-student"
    static let URLallClassmate = baseURL + "api/web/index.php/v1/timetable/get-all-student"
    
    static let URLatk = baseURL + "api/web/index.php/v1/beacon-attendance-student/student-attendance"
    static let URLattendance = baseURL + "api/web/index.php/v1/attendance"
    
    static let URLchangepass = baseURL + "api/web/index.php/v1/user/change-password"
    static let URLchangedevice = baseURL + "api/web/index.php/v1/student/register-device"
    static var device_token = ""

    static let photoURL = "http://128.199.93.67/WeTrack/backend/web/"
    static var token = ""
    static var username = ""
    static var name = ""
    static var password = ""
    static var major : Int = 0
    static var minor : Int = 0
    static var student_id : Int = 0
    static var email = "np@gmail.com"
    static var noti = true
    static var isScanning = true
    static var userphoto = URL(string: "")
    
    static var isLogin = false
    static var device_hash = ""
    static var change_device = false
    
}

struct GlobalData{
    
    static var timetable = [Lesson]()
    static var today = [Lesson]()
    static var lessonUUID = [Int:String]()
    static var currentLesson = Lesson()
    static var classmates = [Classmate]()
    static var history = [History]()
    
    static var attendance = [Int]()
    static var currentDateStr = ""
    static var currentLecturerMajor = 0
    static var currentLecturerMinor = 0
    static var currentLecturerId = 0
 
}




