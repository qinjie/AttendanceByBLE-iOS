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
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import SwiftyTimer
import SwiftyBeaver
let log = SwiftyBeaver.self
import Foundation
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate,CBPeripheralManagerDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
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
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        /*UNUserNotificationCenter.current().delegate = self
         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
         (success, error) in
         if success {
         log.info("granted noti")
         }
         else {
         log.info("denided noti")
         }
         guard success else {return}
         self.getNotificationSettings()
         }
         let type: UIUserNotificationType = [UIUserNotificationType.alert, .badge, .sound]
         let settings = UIUserNotificationSettings(types: type, categories: nil)
         application.registerUserNotificationSettings(settings)*/
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton),
                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userFailed), name: Notification.Name(rawValue: "userFailed"), object: nil)
        
        //add log destinations.
        let console = ConsoleDestination() // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file
        let cloud = SBPlatformDestination(appID: "0G8vQ1", appSecret: "ieuq2buxAk4hOpxs6xhekpAizbbdlhsG", encryptionKey: "nFjc1oWmxr3morgyouJrtn1xzd0sNzg4")
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        //console.format = "$Dyyy-MM-dd HH:mm:sss$d $N.$F:$l $L: $M"
        //use this for JSON output: console.format = "$J"
        
        //add the destinations to SwifyBeaver
        log.addDestination(console)
        log.addDestination(file)
        //file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        log.addDestination(cloud)        
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            log.info(aps)
        }
        
        return true
    }
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    public func uploadComment() {
        let headers: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        var data = Data()
        data = "aa".data(using: .utf8)!
        let url = try! URLRequest(url: Constant.URLLogFile, method: .post, headers: headers)
        let Name = "iOS_\(UserDefaults.standard.string(forKey: "student_id")!)_feedback)"
        Alamofire.upload(multipartFormData: {(MultipartFormData) in
            MultipartFormData.append(data, withName: "logFile", fileName: Name, mimeType: "text/plain")
            
        }, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    print("MultipartFormData@@@@@@@@@@@@@\(data.endIndex)")
                    print("response.request\(String(describing: response.request))")  // original URL request
                    print("response.response\(String(describing: response.response))" ) // URL response
                    print("response.data\(String(describing: response.data))")     // server data
                    print(response.result)   // result of response serialization
                    //remove the file
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    public func uploadLogFile() {
        let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileurl = cacheDirURL.appendingPathComponent("swiftybeaver").appendingPathExtension("log")
        //let pathString = fileurl.path
        let filename = fileurl.lastPathComponent
        print("File Path: \(fileurl.path)")
        print("File name: \(filename)")
        var readString = ""
        do{
            readString = try String(contentsOf: fileurl)
        }
        catch let error as NSError {
            print("Failed to read file")
            print(error)
        }
        //print("~~~~~~~~~~~~~~~`Contents of file \(readString)")
        let headers: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
      
        let url = try! URLRequest(url: Constant.URLLogFile, method: .post, headers: headers)
        var data = Data()
        if let fileContents = FileManager.default.contents(atPath: fileurl.path) {
            data = fileContents as Data
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: date)
        let Name = "iOS_\(result)_\((GlobalData.currentLesson.lesson_id)!)_\(UserDefaults.standard.string(forKey: "student_id")!)"
        print("Name&&&&&&&&&&&&&&&&\(Name)")
        Alamofire.upload(multipartFormData: {(MultipartFormData) in
            MultipartFormData.append(data, withName: "logFile", fileName: Name, mimeType: "text/plain")
            /*for (key,_) in parameters {
                let name = String(key)
                if let value = parameters[name] as? String {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            }*/
           
        }, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    print("MultipartFormData@@@@@@@@@@@@@\(data.endIndex)")
                    print("response.request\(String(describing: response.request))")  // original URL request
                    print("response.response\(String(describing: response.response))" ) // URL response
                    print("response.data\(String(describing: response.data))")     // server data
                    print(response.result)   // result of response serialization
                    //remove the file
                    if response.response?.statusCode == 200{
                        self.deleteLogFile()
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    func deleteLogFile(){
        let file = FileDestination()
        let _  = file.deleteLogFile()
    }
    func downloadLogFile(filename: String) {
        let parameters: [String: Any] = [
            "filename": filename
        ]
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("haha.txt")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(Constant.URLDownLogFile, method: .post, parameters: parameters, to: destination).response {
            response in
            let cacheDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileurl = cacheDirURL.appendingPathComponent("haha").appendingPathExtension("txt")
            //let pathString = fileurl.path
            let filename = fileurl.lastPathComponent
            print("File Path: \(fileurl.path)")
            print("File name: \(filename)")
            var readString = ""
            do{
                readString = try String(contentsOf: fileurl)
            }
            catch let error as NSError {
                print("Failed to read file")
                print(error)
            }
           // print("~~~~~~~~~~~~~~~`Contents of file \(readString)")
            /////////////////////////////////////
            print("Response\(response)")
            if let path = response.destinationURL?.path {
                let data = FileManager.default.contents(atPath: path)
                print("Data\(String(describing: data))")
            }
        }
    }

    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    @objc func tokenRefreshNotificaiton(notification: NSNotification) {
        let refreshedToken = InstanceID.instanceID().token()!
        print("InstanceID token: \(refreshedToken)")
        //User.sharedUser.googleUID = refreshedToken
        Messaging.messaging().shouldEstablishDirectChannel = true
        
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings{(settings) in
            print("Notification settings: \(settings)")
        }
    }
    //use the device token as "address" to deliver notifications to the correct devices
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
        InstanceID.instanceID()
        let take = Messaging.messaging().fcmToken
        log.info("FCMToken \(String(describing:take))")
    }
    @nonobjc func application(_ application: UIApplication, didRegister notificationSettings: UNNotificationSettings)
    {
        application.registerForRemoteNotifications()
    }
    func application(received: MessagingRemoteMessage){
        print("%@", received.appData)
    }
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("//////////////////////////////+\(userInfo)")
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("00000000000000 Message ID: \(messageID)")
        }
        print("Message ID: \(userInfo)")
        
        
        // Print full message.
        print(userInfo)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("1111111111Message ID: \(messageID)")
        }
        print("Message ID: \(userInfo)")
        /* if (userInfo["subject"] != nil && userInfo["to_user_ids"] != nil){
         
         let notification = UILocalNotification()
         notification.alertBody = userInfo["subject"] as? String // text that will be displayed in the notification
         notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
         notification.fireDate = NSDate.init() // todo item due date (when notification will be fired). immediately here
         notification.soundName = UILocalNotificationDefaultSoundName // play default sound
         UIApplication.sharedApplication().scheduleLocalNotification(notification)
         }
         }*/
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
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
                "lecturer_id": Constant.identifier,
                "student_id": Constant.student_id,
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
                    NotificationCenter.default.post(name: Notification.Name(rawValue:"taken"), object: nil)
                    
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
        //completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceived response: UNNotificationResponse, withCompletionHandler: @escaping (() -> Void) ){
        print("background notification received!!!!!!")
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
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        /*if identifier != UIBackgroundTaskInvalid {
         endBackgroundTask()
         }*/
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Messaging.messaging().shouldEstablishDirectChannel = true
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


