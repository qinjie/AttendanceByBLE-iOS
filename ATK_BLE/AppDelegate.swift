//
//  AppDelegate.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var foundLecturer = false
    var foundClassmate = false
    var numofdetected = 0
    var id1 = ""
    var id2 = ""
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                var loginController: LoginController? = (mainStoryboard.instantiateViewController(withIdentifier: "LoginPage") as? LoginController)
//                 self.window?.rootViewController = loginController
        if (UserDefaults.standard.string(forKey: "username") == nil) {
            
            let loginController: LoginController? = (mainStoryboard.instantiateViewController(withIdentifier: "LoginPage") as? LoginController)
            
            self.window?.rootViewController = loginController
        }else{
            
            let mainViewController: TabbarController? = (mainStoryboard.instantiateViewController(withIdentifier: "Home") as? TabbarController)
            
            self.window?.rootViewController = mainViewController
        }
        

        
        // Override point for customization after application launch.
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        NotificationCenter.default.addObserver(self,selector: #selector(sendnoti), name: NSNotification.Name(rawValue: "openapp"), object: nil)
        
        return true
    }
    
    func sendnoti(){
        noti(content: "Please open to take attendance")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFailForRegion - error: \(error.localizedDescription)")
        print("monitoringDidFailForRegion - error: \(String(describing: region?.identifier))")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring \(region.identifier) region")
        
        //noti(content: "start " + region.identifier)
        
    }
    
    func noti(content : String){
        let notification = UILocalNotification()
        notification.alertBody = content
        notification.soundName = "Default"
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        print("Stop monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        
        print("@3: -____- state \(region.identifier)" )
        switch state {
        case .inside:
            print(" >>>> bg Inside \(region.identifier)");
            
            noti(content: "Please open to take attendance")
            
                  //take attendance
                Constant.token = UserDefaults.standard.string(forKey: "token")!
                Constant.student_id = UserDefaults.standard.integer(forKey: "student_id")
            
                let para1: Parameters = [
                        "lesson_date_id": GlobalData.currentLesson.ldateid!,
                        "student_id_1": Constant.student_id,
                        "student_id_2": region.identifier,
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
                        GlobalData.attendance.append(GlobalData.currentLesson.ldateid!)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
                                                
                    }
                        if let data = response.result.value{
                            print(data)
                        }
                        
                }
                
         
            
//            if (region.identifier == GlobalData.currentLecturerId.description){
//                foundLecturer = true
//            }else{
//                foundClassmate = true
//            }
//            
        //report(region: CLRegion)
        case .outside:
            print(" -____- Outside");
            
            // noti(content: "OUTSIDE  " + region.identifier)
            
        case .unknown:
            print(" -____- Unknown");
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //print("@1: did enter region!!!")
        
        if (region is CLBeaconRegion) {
         
            print(">>>> bg enter region!!!  \(region.identifier)" )
            
            //   noti(content: "ENTER  " + region.identifier)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        // print("@1: did exit region!!!")
        
        if (region is CLBeaconRegion) {
            print("@2: did exit region!!!   \(region.identifier)")
            //noti(content: "ATK-EXIT " + region.identifier)
        }
    }
    
    
    func resetAppToFirstController() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController: LoginController? = (mainStoryboard.instantiateViewController(withIdentifier: "LoginPage") as? LoginController)
        self.window?.rootViewController = loginController
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
}
