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
    static let URLstudentlogin = baseURL + "api/web/index.php/v1/student/login"
    static let URLtimetable = baseURL + "api/web/index.php/v1/timetable?expand=lesson,lesson_date,lecturers,venue"
    static let URLmissing = baseURL + "api/web/index.php/v1/resident/missing?expand=beacons,relatives,locations"
    static let URLall = baseURL + "api/web/index.php/v1/resident?expand=relatives,beacons,locations,locationHistories"
    static let URLcreateDeviceTk = baseURL + "api/web/index.php/v1/device-token/new"
    static let URLdelDeviceTk = baseURL + "api/web/index.php/v1/device-token/del"
    static let URLstatus = baseURL + "api/web/index.php/v1/resident/status"
    static var device_token = ""
    
    static let restartTime = 60.0
    static let photoURL = "http://128.199.93.67/WeTrack/backend/web/"
    static var token = ""
    static var username = ""
    static var role = 40
    static var user_id : Int = 0
    static var email = "np@gmail.com"
    static var noti = true
    static var isScanning = true
    static var userphoto = URL(string: "")
    
    static var isLogin = false
    
}

struct GlobalData{
    
   static var timetable = [Lesson]()
   static var today = [Lesson]()
    
}




