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
import AVFoundation
import SwiftyTimer
import SwiftyBeaver
let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate,CBPeripheralManagerDelegate {
    
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var identifier : UIBackgroundTaskIdentifier! = UIBackgroundTaskInvalid
    var bluetoothManager = CBPeripheralManager()
    var id1 = ""
    var id2 = ""
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        bluetoothManager.delegate = self
        bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
        
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
                log.info("granted noti")
            }
            else {
                log.info("denided noti")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(userFailed), name: Notification.Name(rawValue: "userFailed"), object: nil)
        
        //add log destinations.
        let console = ConsoleDestination() // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file
        let cloud = SBPlatformDestination(appID: "0G8vQ1", appSecret: "ieuq2buxAk4hOpxs6xhekpAizbbdlhsG", encryptionKey: "nFjc1oWmxr3morgyouJrtn1xzd0sNzg4")
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        //use this for JSON output: console.format = "$J"
        
        //add the destinations to SwifyBeaver
        log.addDestination(console)
        log.addDestination(file)
        //file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        log.addDestination(cloud)
        
        return true
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var status = ""
        switch peripheral.state {
        case .poweredOff: status = "Bluetooth Status: \n Turned Off"
        case .poweredOn: status = "Bluetooth Status: \n Turned On"
        case .resetting: status = "Bluetooth Status: \n Resetting"
        case .unauthorized: status = "BLuetooth Status: \n Not Authorized"
        case .unsupported: status = "Bluetooth Status: \n Not Supported"
        default: status = "Bluetooth Status: \n Unknown"
        }
        log.info(status)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.info("Start bg monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        log.info("Stop bg monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        
        log.info("bg did determine state \(region.identifier)" )
        switch state {
        case .inside:
            log.info("inside !!!!!")
            checkAttendance.checkAttendance()
            //checkStudent(id: Int(region.identifier)!)
            Constant.identifier = region.identifier
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notTaken"), object: nil)
            NotificationCenter.default.addObserver(self,selector: #selector(takeAttendance), name: NSNotification.Name(rawValue: "notTaken"), object: nil)
        case .outside: log.info("Outside bg \(region.identifier)")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notTaken"), object: nil)
        case .unknown: log.info("Unknown")
        }
    }
    
    private func checkStudent(id:Int){
        var check = false
        for i in GlobalData.tempStudents{
            if i.id == id{
                check = true
            }
        }
        if check == false{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notTaken"), object: nil)
        }
    }
    
    @objc func takeAttendance() {
        if Constant.change_device == true{
            
        }else{
            log.info(" bg Inside \(Constant.identifier)");
            Constant.token = UserDefaults.standard.string(forKey: "token")!
            Constant.student_id = UserDefaults.standard.integer(forKey: "student_id")
            
            let para1: Parameters = [
                "lesson_date_id": GlobalData.currentLesson.ldateid!,
                "student_id_1": Constant.student_id,
                "student_id_2": Constant.identifier,
                ]
            
            
            let parameters: [String: Any] = ["data": [para1]]
            
            log.info(parameters)
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + Constant.token,
                "Content-Type": "application/json"
            ]
            
            Alamofire.request(Constant.URLatk, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                
                let statusCode = response.response?.statusCode
                if (statusCode == 200){
                    GlobalData.myAttendance.append(GlobalData.currentLesson.ldateid!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
                    let systemSoundID: SystemSoundID = 1315
                    AudioServicesPlaySystemSound(systemSoundID)
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
                    let content = notification.notiContent(title: "successful", body: "You have successfully taken attendance")
                    notification.addNotification(trigger: trigger, content: content, identifier: "a")
                    //Save record locally
                    let tempStudent = TempStudents()
                    tempStudent.id = Int(Constant.identifier)
                    GlobalData.tempStudents.append(tempStudent)
                    NSKeyedArchiver.archiveRootObject(GlobalData.tempStudents, toFile: filePath.tempStudents)
                }
                if let data = response.result.value{
                    log.info("///////////////result below////////////")
                    log.info(data)
                }
                
            }

        }
        
    }
    func testSendNoti() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        let content = notification.notiContent(title: "successfull", body: "You have successfully taken attendance")
        notification.addNotification(trigger: trigger, content: content, identifier: "a")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active { // In iOS 10 if app is in foreground do nothing.
            completionHandler([])
        } else { // If app is not active you can show banner, sound and badge.
            completionHandler([.alert, .badge, .sound])
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log.info(" bg enter region!!!  \(region.identifier)" )
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log.info("bg did exit region!!!   \(region.identifier)")
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        log.info("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        registerBackgroundTask()
        GlobalData.lastLesson = GlobalData.currentLesson
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserDefaults.standard.string(forKey: "student_id") != nil{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enter foreground"), object: nil)
            Timer.after(3, {
                NotificationCenter.default.post(name: Notification.Name(rawValue:"detect lecturer"), object: nil)
            })
        }
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
        
        if let lecturers = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.lecturerPath) as? [Lecturer]{
            GlobalData.lecturers = lecturers
        }
        
        if let lessonuuid = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.lessonuuidPath) as? [Int : String]{
            GlobalData.lessonUUID = lessonuuid
        }
        
        if let history = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.historyPath) as? [History]{
            GlobalData.history = history
        }
        
        if let historyDT = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.historyDTPath) as? [Lesson]{
            GlobalData.attendance = historyDT
            HistoryBrain.arrangeHistory()
        }
        
        if let tempStudents = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.tempStudents) as? [TempStudents]{
            GlobalData.tempStudents = tempStudents
        }
        
    }
}


