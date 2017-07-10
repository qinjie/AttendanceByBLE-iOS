//
//  AppDelegate.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import Alamofire
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var identifier : UIBackgroundTaskIdentifier! = UIBackgroundTaskInvalid
    var id1 = ""
    var id2 = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        if UserDefaults.standard.string(forKey: "student_id") != nil{
            self.loadData()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let home:UITabBarController = (mainStoryboard.instantiateViewController(withIdentifier: "home") as? UITabBarController)!
            self.window?.rootViewController = home
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (success, error) in
            if success {
                print("granted noti")
            }
            else {
                print("denided noti")
            }
        }
        UIApplication.shared.cancelAllLocalNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userFailed), name: Notification.Name(rawValue: "userFailed"), object: nil)
        return true
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Start bg monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        print("Stop bg monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        
        print("bg did determine state \(region.identifier)" )
        switch state {
        case .inside:
            print("inside liao")
            checkAttendance.checkAttendance()
            Constant.identifier = region.identifier
            NotificationCenter.default.addObserver(self,selector: #selector(takeAttendance), name: NSNotification.Name(rawValue: "notTaken"), object: nil)
        case .outside: print("Outside bg \(region.identifier)")
        case .unknown: print("Unknown")
        }
    }
    func takeAttendance() {
        print(" bg Inside \(Constant.identifier)");
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        Constant.student_id = UserDefaults.standard.integer(forKey: "student_id")
        
        let para1: Parameters = [
            "lesson_date_id": GlobalData.currentLesson.ldateid!,
            "student_id_1": Constant.student_id,
            "student_id_2": Constant.identifier,
            ]
        
        
        let parameters: [String: Any] = ["data": [para1]]
        
        print(parameters)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constant.URLatk, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            let statusCode = response.response?.statusCode
            if (statusCode == 200){
                GlobalData.myAttendance.append(GlobalData.currentLesson.ldateid!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
                print("gl\(GlobalData.attendance)")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
                let content = checkAttendance.notiContent(title: "successfull", body: "You have successfully taken attendance")
                checkAttendance.addNotification(trigger: trigger, content: content, identifier: "a")
                
            }
            if let data = response.result.value{
                print("///////////////result below////////////")
                print(data)
            }
            
        }
    }
    func testSendNoti() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        let content = checkAttendance.notiContent(title: "successfull", body: "You have successfully taken attendance")
        checkAttendance.addNotification(trigger: trigger, content: content, identifier: "a")            }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(" bg enter region!!!  \(region.identifier)" )
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("bg did exit region!!!   \(region.identifier)")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(identifier)
        self.identifier = UIBackgroundTaskInvalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTime"), object: nil)
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        /*if identifier != UIBackgroundTaskInvalid {
         endBackgroundTask()
         }*/
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc private func userFailed(){
        let alert = UIAlertController(title: "Invalid token", message: "Session expired", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (UIAlertAction) in
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let login:LoginController = (mainStoryboard.instantiateViewController(withIdentifier: "sign in") as? LoginController)!
            self.window?.rootViewController = login
        }))
    }
    
    private func loadData(){
        
        if let timetable = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.timetablePath) as? [Lesson]{
            GlobalData.timetable = timetable
        }
        
        if let classmates = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.classmatePath) as? [Classmate]{
            GlobalData.classmates = classmates
        }
        
        if let lessonuuid = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.lessonuuidPath) as? [Int : String]{
            GlobalData.lessonUUID = lessonuuid
        }
        if let history = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.historyPath) as? [HistoryOA]{
            GlobalData.history = history
        }
        
        if let historyDT = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.historyDTPath) as? [HistoryDT]{
            GlobalData.attendance = historyDT
        }
        
    }
}

struct filePath{
    static var timetablePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("timetable").path
    }
    
    static var classmatePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("classmate").path
    }
    
    static var lessonuuidPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("lessonuuid").path
    }
    static var historyPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("history").path
    }
    static var historyDTPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("historyDT").path
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

