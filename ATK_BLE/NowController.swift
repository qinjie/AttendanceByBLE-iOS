//
//  NowController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire
import CoreBluetooth
import CoreLocation
import UserNotifications
import AVFoundation

class NowController: UIViewController,UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noLessonLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var broadcastLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var today = Date()
    var currentTimeStr = ""
    var currentLesson:Lesson!
    var nextLesson:Int!
    var timer:Timer?
    
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var isGrantedNotificationAccess = false
    
    var lecturerMajor: Int! = 0
    var lecturerMinor: Int! = 0
    var uuid: UUID!
    var dataDictionary = NSDictionary()
    var classmate = Classmate()
    var lecturer = Lecturer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()  // to receive local notification from other view
        checkDevice()   // check if this is new device
        GlobalData.timetable.sort(by: {$0.start_time! < $1.start_time!})
        broadcastLabel.isHidden = true
        setupImageView()
        locationManager.delegate = self
        bluetoothManager.delegate = self
        bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        setupTimer()    //For every lesson before 10 mins
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
         appdelegate.uploadLogFile()
        //let result = appdelegate.deleteLogFile()
        //if (result){
        ///   print("LOG FILE DELETED")
        //}
        
        //appdelegate.downloadLogFile(filename: "kyizar")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func setupTimer(){
        if UserDefaults.standard.string(forKey: "notification time") == nil{
            UserDefaults.standard.set("10", forKey: "notification time")
        }
        var date = Format.Format(date: Date(), format: "HH:mm:ss")
        let upcomingLesson = GlobalData.today.filter({$0.start_time! > date})
        for i in upcomingLesson{
            date = Format.Format(date: Date(), format: "HH:mm:ss")
            let start_time = Format.Format(string: i.start_time!, format: "HH:mm:ss")
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: Format.Format(string: date, format: "HH:mm:ss"), to: start_time)
            let time = Int(UserDefaults.standard.string(forKey: "notification time")!)!
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - time*60)
            if interval > 0 {
                let notificationContent = notification.notiContent(title: "Upcoming lesson", body: "\(String(describing: i.catalog!)) \(String(describing: i.class_section!)) \(String(describing: i.location!))")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: String(describing:i.ldateid))
            }
            
        }
        
        for i in upcomingLesson{
            date = Format.Format(date: Date(), format: "HH:mm:ss")
            let start_time = Format.Format(string: i.start_time!, format: "HH:mm:ss")
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: Format.Format(string: date, format: "HH:mm:ss"), to: start_time)
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second!)
            if interval > 0 {
                let notificationContent = notification.notiContent(title: "Lesson started", body: "Please open your app to take attendance")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: String(describing:i.ldateid)+"lesson time")
            }
            
        }
        
    }
    
    private func addObservers(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(setupTimer), name: NSNotification.Name(rawValue: "stepper changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: NSNotification.Name(rawValue: "done loading timetable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: NSNotification.Name(rawValue: "enter foreground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detectLecturer), name: NSNotification.Name(rawValue: "update time"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(success), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(attendanceTaken), name: NSNotification.Name(rawValue: "taken"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(enableImageView), name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notTaken), name: Notification.Name(rawValue: "notTaken"), object: nil)
        
    }
    
    @objc func enableImageView(){
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func notTaken(){
        imageView.image = #imageLiteral(resourceName: "blue-on")
    }
    
    @objc func attendanceTaken(){
        Timer.after(2) {
            for i in self.locationManager.monitoredRegions{
                self.locationManager.stopMonitoring(for: i)
            }
        }
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        self.imageView.stopAnimating()
        imageView.isUserInteractionEnabled = false
        imageView.image = #imageLiteral(resourceName: "blue-off")
        self.currentTimeLabel.text = "Your attendance is taken"
        self.currentTimeLabel.textColor = UIColor(red: 0.1412, green: 0.6078, blue: 0, alpha: 1.0)
    }
    private func checkDevice(){
        
        if Constant.change_device == true{
            let deviceAlertController = UIAlertController(title: "New Device", message: "Do you want to continue to use this device?\nYes:Can only take attendance tommorrow\nNo:Can take attendance using old device", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction) in
                Constant.change_device = true
                self.changeDevice()
            })
            let noAction =  UIAlertAction(title: "No", style: .default, handler: { (action:UIAlertAction) in
                Constant.change_device = true
            })
            deviceAlertController.addAction(yesAction)
            deviceAlertController.addAction(noAction)
            self.present(deviceAlertController, animated: false, completion: nil)
        }else{
            checkUserInBackGround()
        }
        
    }
    
    private func changeDevice(){
        let this_device = UIDevice.current.identifierForVendor?.uuidString
        let username = UserDefaults.standard.string(forKey: "username")!
        let password = UserDefaults.standard.string(forKey: "password")!
        let parameters:[String:Any] = [
            "username" : username,
            "password" : password,
            "device_hash" : this_device!
        ]
        let headers:HTTPHeaders = [
            "Content-Type" : "application/json"
        ]
        Alamofire.request(Constant.URLchangedevice, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
            log.info("Changed device result: " + String(describing: response.response!.statusCode))
            if response.response?.statusCode != 200{
                log.warning("Device_hash exists: " + this_device!)
                let alertController = UIAlertController(title: "Device already in used", message: "This device is linked to another student's account.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    alertController.dismiss(animated: false, completion: nil)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: false, completion: nil)
            }
            
        })
    }
    
    private func stopLiao(){
        print("Stop Advertising!!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func setupTitle(){
        
        let date = Date()
        let today = Format.Format(date: date, format: "EEE")
        let todayDate = Format.Format(date: date, format: "dd MMM")
        navigationItem.title = today + "(" + todayDate + ")"
        
    }
    
    private func setupImageView(){
        
        imageView.isUserInteractionEnabled = false
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(broadcastSignal))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
        
    }
    @objc private func success() {
        self.currentTimeLabel.text = "Your attendance is taken"
        self.currentTimeLabel.textColor = UIColor(red: 0.1412, green: 0.6078, blue: 0, alpha: 1.0)
        self.currentTimeLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
    }
    
    @objc private func broadcastSignal() {
        if currentLesson != nil {
            if imageView.isAnimating{
                
            }else{
                broadcast()
            }
        }
        else{
            updateLabels()
        }
        
    }
    
    private func turnOnBlt() {
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    @objc func stopBroadcast() {
        bluetoothManager.stopAdvertising()
        self.imageView.stopAnimating()
    }
    
    @objc private func detectLecturer() {
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
        let lecturerRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(GlobalData.currentLecturerMajor)as CLBeaconMajorValue, minor: UInt16(GlobalData.currentLecturerMinor)as CLBeaconMinorValue, identifier: GlobalData.currentLecturerId.description)
        locationManager.startMonitoring(for: lecturerRegion)
        log.info(uuid)
        log.info(GlobalData.currentLecturerMajor)
        log.info(GlobalData.currentLecturerMinor)
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
    
    func broadcastTime(time:Int) {
        let rand = time + Int(arc4random_uniform(3))
        let x = rand * 60
        let date = Date().addingTimeInterval(TimeInterval(x))
        print("date \(date)")
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(broadcast), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    @objc func broadcast() {
        
        if bluetoothManager.state == .poweredOn {
            if Constant.change_device == true{
                let alertController = UIAlertController(title: "New Device", message: "Cannot take attendance with this device\nNew device can attendance after the day register", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: false, completion: nil)
            }else{
                imageView.animationImages = [
                    #imageLiteral(resourceName: "blue-1"),
                    #imageLiteral(resourceName: "blue-2"),
                    #imageLiteral(resourceName: "blue-3")
                ]
                imageView.animationDuration = 0.5
                imageView.startAnimating()
            }
            log.info("broadcasting")
            if self.timer == nil{
                self.timer = Timer.every(3, {
                    checkAttendance.checkAttendance()
                })
            }
            let major = UInt16(Int(UserDefaults.standard.string(forKey: "major")!)!)as CLBeaconMajorValue
            let minor = UInt16(Int(UserDefaults.standard.string(forKey: "minor")!)!)as CLBeaconMinorValue
            uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "\(String(describing: UserDefaults.standard.string(forKey: "student_id")!))")
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
            
            let date = Date().addingTimeInterval(TimeInterval(120))
            let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(stopBroadcast), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
        else {
            let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " AME would like to turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { action in
                self.turnOnBlt()
                self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    private func testSendNoti() {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let content = notification.notiContent(title: "successful", body: "You have successfully taken attendance")
        notification.addNotification(trigger: trigger, content: content, identifier: "abc")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.info("Started monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        log.info("Stop monitoring \(region.identifier) region")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did exit region!!! \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            log.info("did enter region!!! \(region.identifier)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        log.info("fg did determine state!!!!!")
        switch(state) {
        case .inside:log.info("fg inside\(region.identifier)")
        case .outside:log.info("fg outside\(region.identifier)")
        case .unknown:log.info("fg unknown\(region.identifier)")
        }
    }
    
    @objc private func checkTime(){
        log.info("checking time")
        self.setupTitle()
        nextLesson = 1
        //check if today have lessons
        if checkLesson.checkCurrentLesson() == true {
            
            checkAttendance.checkAttendance()
            currentLesson = GlobalData.currentLesson
            subjectLabel.text = currentLesson.subject! + " " + currentLesson.catalog!
            classLabel.text = currentLesson.class_section
            timeLabel.text = displayTime.display(time: currentLesson.start_time!) + " - " + displayTime.display(time: currentLesson.end_time!)
            venueLabel.text = currentLesson.location
            currentTimeLabel.textColor = UIColor.gray
            currentTimeLabel.text = "Waiting for \nlecturer's beacon"
            GlobalData.currentLesson = currentLesson
            //imageView.image = #imageLiteral(resourceName: "blue-on")
            log.info("Self.classmatesall \(GlobalData.classmates.count)!")
            //print("Current Lesson : \(GlobalData.lessonUUID)")
            self.lecturer = GlobalData.lecturers.filter({$0.lec_id == currentLesson.lecturer_id}).first!
            GlobalData.currentLecturerId = lecturer.lec_id!
            GlobalData.currentLecturerMajor = lecturer.major!
            GlobalData.currentLecturerMinor = lecturer.minor!
            /*self.classmate = GlobalData.classmates.filter({($0.lesson_id! == currentLesson.lesson_id!)}).first!
             print("Students  \(String(describing: self.classmate.student_id?.count))")*/
            log.info("\(String(describing: GlobalData.currentLesson.catalog))")
            log.info(UserDefaults.standard.string(forKey: "student_id")!)
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"detect lecturer"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(detectLecturer), name: Notification.Name(rawValue: "detect lecturer"), object: nil)
        }else{
            currentLesson = nil
            if checkLesson.checkNextLesson() == true{
                nextLessonRefresh()
                let nLesson = GlobalData.nextLesson
                //Estimate the next lesson time
                subjectLabel.text = nLesson.subject! + " " + nLesson.catalog!
                classLabel.text = nLesson.class_section
                timeLabel.text = displayTime.display(time: nLesson.start_time!) + " - " + displayTime.display(time: nLesson.end_time!)
                venueLabel.text = nLesson.venueName
                currentTimeLabel.text = GlobalData.nextLessonTime
            }else{
                GlobalData.currentLesson.ldateid = nil
                self.nextLesson = nil
                
            }
        }
        updateLabels()
    }
    
    private func nextLessonRefresh(){
        let nLesson = GlobalData.nextLesson
        let date = Format.Format(date: Date(), format: "HH:mm:ss")
        let start_time = Format.Format(string: nLesson.start_time!, format: "HH:mm:ss")
        let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: Format.Format(string: date, format: "HH:mm:ss"), to: start_time)
        let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second!)
        if interval > 0 {
            
            let nTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(checkTime), userInfo: nil, repeats: false)
            RunLoop.main.add(nTimer, forMode: RunLoopMode.commonModes)
            
        }
        
    }
    
    private func updateLabels(){
        
        if nextLesson == nil{
            subjectLabel.isHidden = true
            classLabel.isHidden = true
            timeLabel.isHidden = true
            noLessonLabel.isHidden = false
            venueLabel.isHidden = true
            currentTimeLabel.isHidden = true
            imageView.isHidden = true
            broadcastLabel.isHidden = true
            
        }else if currentLesson == nil{
            
            subjectLabel.isHidden = false
            classLabel.isHidden = false
            timeLabel.isHidden = false
            noLessonLabel.isHidden = true
            venueLabel.isHidden = false
            currentTimeLabel.isHidden = false
            imageView.isHidden = false
            broadcastLabel.isHidden = false
            currentTimeLabel.textColor = UIColor.gray
            imageView.image = #imageLiteral(resourceName: "blue-off")
            broadcastLabel.isHidden = true
            broadcastLabel.textColor = UIColor.gray
            
        }else{
            
            subjectLabel.isHidden = false
            classLabel.isHidden = false
            timeLabel.isHidden = false
            noLessonLabel.isHidden = true
            venueLabel.isHidden = false
            currentTimeLabel.isHidden = false
            imageView.isHidden = false
            broadcastLabel.isHidden = false
            broadcastLabel.isUserInteractionEnabled = true
            
        }
    }
    
    private func checkUserInBackGround(){
        
        log.info("Checking user in background")
        let this_device = UIDevice.current.identifierForVendor?.uuidString
        let parameters:[String:Any] = [
            "username" : UserDefaults.standard.string(forKey: "username")!,
            "password" : UserDefaults.standard.string(forKey: "password")!,
            "device_hash" : this_device!
        ]
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: self.view.frame.width/2,y: self.view.frame.height/2)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        self.view.addSubview(spinnerIndicator)
        let token = UserDefaults.standard.string(forKey: "token")!
        let headersTimetable:HTTPHeaders = [
            "Authorization" : "Bearer " + token
        ]
        Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersTimetable).responseJSON { (response:DataResponse) in
            let code = response.response?.statusCode
            if code == 200{
                Alamofire.request(Constant.URLstudentlogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                    let code = response.response?.statusCode
                    spinnerIndicator.removeFromSuperview()
                    log.info("Status code : " + String(describing: code))
                    if code == 200{
                        if let json = response.result.value as? [String:AnyObject]{
                            UserDefaults.standard.set(json["token"], forKey: "token")
                            let status = json["status"] as? Int
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
                            self.checkTime()
                            if status != 10{
                                Constant.change_device = true
                            }else{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"detect lecturer"), object: nil)
                            }
                        }
                    }
                }
            }else if (code!>=400) && (code!<=500){
                NotificationCenter.default.post(name: Notification.Name(rawValue: "userFailed"), object: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
struct displayTime {
    static func display(time: String) -> String{
        let timeSplit = time.components(separatedBy: ":")
        let hour = timeSplit[0]
        let minute = timeSplit[1]
        return hour + ":" + minute
    }
}

