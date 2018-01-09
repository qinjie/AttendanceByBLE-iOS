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
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        UNUserNotificationCenter.current().delegate = self
        setupTimer()    //For every lesson before 10 mins
        if !appdelegate.isInternetAvailable(){
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
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
        
    }
    
    private func addObservers(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(setupTimer), name: NSNotification.Name(rawValue: "stepper changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: NSNotification.Name(rawValue: "done loading timetable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: NSNotification.Name(rawValue: "enter foreground"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(success), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(attendanceTaken), name: NSNotification.Name(rawValue: "taken"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(enableImageView), name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notTaken), name: Notification.Name(rawValue: "notTaken"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detectLecturer), name: Notification.Name(rawValue: "detect lecturer"), object: nil)
        
    }
    
    @objc func enableImageView(){
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func notTaken(){
        self.detectLecturer()
        let timeInterval = Format.Format(string: Format.Format(date: Date(), format: "HH:mm:ss"), format: "HH:mm:ss").timeIntervalSince(Format.Format(string: currentLesson.start_time!, format: "HH:mm:ss"))
        if timeInterval >= 0{
            imageView.isUserInteractionEnabled = true
            imageView.image = #imageLiteral(resourceName: "blue-on")
            broadcastLabel.isHidden = false
        }else{
            imageView.isUserInteractionEnabled = false
            imageView.image = #imageLiteral(resourceName: "blue-off")
            broadcastLabel.isHidden = true
        }
    }
    
    @objc func attendanceTaken(){
        Timer.after(2) {
            for i in self.locationManager.monitoredRegions{
                self.locationManager.stopMonitoring(for: i)
            }
        }
        
        if timer != nil{
            if let start_time = UserDefaults.standard.string(forKey: "broadcast time"){
                let end_time = Format.Format(date: Date(), format: "HH:mm:ss")
                let time_interval = Format.Format(string: end_time, format: "HH:mm:ss").timeIntervalSince(Format.Format(string: start_time, format: "HH:mm:ss"))
                log.debug("[Performance] " + String(describing:time_interval))
            }
        }
        
        self.stopBroadcast()
        imageView.isUserInteractionEnabled = false
        imageView.image = #imageLiteral(resourceName: "blue-off")
        broadcastLabel.isHidden = true
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
                self.checkTime()
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
            }else{
                self.checkTime()
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
    private func turnOnData() {
        let url = URL(string: "App-Prefs:root=WIFI") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    @objc func stopBroadcast() {
        
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        
        bluetoothManager.stopAdvertising()
        self.imageView.stopAnimating()
        broadcastLabel.textColor = UIColor.black
        broadcastLabel.text = "Broadcast my beacon"
        log.info("Stop Broadcasting")
    }
    
    @objc private func detectLecturer() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"detect lecturer"), object: nil)
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
        let lecturerRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(GlobalData.currentLecturerMajor)as CLBeaconMajorValue, minor: UInt16(GlobalData.currentLecturerMinor)as CLBeaconMinorValue, identifier: GlobalData.currentLecturerId.description)
        locationManager.startMonitoring(for: lecturerRegion)
        log.info("Lesson UUID : \(uuid!)")
        log.info("Lecturer Major : \(GlobalData.currentLecturerMajor)")
        log.info("Lecturer Minor : \(GlobalData.currentLecturerMinor)")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var status = ""
        switch peripheral.state {
        case .poweredOff: status = "Bluetooth Status: Turned Off"
        case .poweredOn: status = "Bluetooth Status: Turned On"
        case .resetting: status = "Bluetooth Status: Resetting"
        case .unauthorized: status = "BLuetooth Status: Not Authorized"
        case .unsupported: status = "Bluetooth Status: Not Supported"
        default: status = "Bluetooth Status: Unknown"
        }
        log.info(status)
    }
    
    @objc func broadcast() {
        
        if bluetoothManager.state == .poweredOn {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if appdelegate.isInternetAvailable() == true {
                if Constant.change_device == true{
                    let alertController = UIAlertController(title: "New Device", message: "Cannot take attendance with this device\nNew device can attendance after the day register", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: false, completion: nil)
                }else{
                    
                    imageView.animationImages = [
                        #imageLiteral(resourceName: "blue_1"),
                        #imageLiteral(resourceName: "blue_2"),
                        #imageLiteral(resourceName: "blue_3")
                    ]
                    imageView.animationDuration = 0.5
                    imageView.startAnimating()
                    let major = UInt16(Int(UserDefaults.standard.string(forKey: "major")!)!)as CLBeaconMajorValue
                    let minor = UInt16(Int(UserDefaults.standard.string(forKey: "minor")!)!)as CLBeaconMinorValue
                    uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
                    let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "\(String(describing: UserDefaults.standard.string(forKey: "student_id")!))")
                    dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                    bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
                    
                    log.info("broadcasting")
                    if self.timer == nil{
                        self.timer = Timer.every(3, {
                            checkAttendance.checkAttendance()
                        })
                    }
                    UserDefaults.standard.set(Format.Format(date: Date(), format: "HH:mm:ss"), forKey: "broadcast time")
                    broadcastLabel.textColor = UIColor.blue
                    broadcastLabel.text = "Broadcasting..."
                    let nTimer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(stopBroadcast), userInfo: nil, repeats: false)
                    RunLoop.main.add(nTimer, forMode: RunLoopMode.commonModes)
                }
            }
            else {
                let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
                /* alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                 self.turnOnData()
                 self.broadcast()
                 self.dismiss(animated: true, completion: nil)
                 }))*/
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        else {
            let alert = UIAlertController(title: "Bluetooth Turn on Request", message: "Please turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    private func testSendNoti() {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let content = notification.notiContent(title: "successful", body: "You have successfully taken attendance")
        notification.addNotification(trigger: trigger, content: content, identifier: "abc")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.debug("Started monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        log.info("Stop monitoring \(region.identifier) region")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            log.info("did exit region!!! \(region.identifier)")
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
        
        //check if this is a new week
        let date = Format.Format(date: Date(), format: "EEEE")
        print("today----> \(date)")
        if date == "Monday"{
            if let week = UserDefaults.standard.string(forKey: "week"){
                if date != week{
                    alamofire.loadTimetable()
                    UserDefaults.standard.set(date, forKey: "week")
                }
            }else{
                UserDefaults.standard.set(date, forKey: "week")
            }
        }
        //check location services enabled?
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                break
            default:
                let alertController = UIAlertController(title: "Location Services", message: "Please always allow location services for background functions", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                        // If general location settings are disabled then open general location settings
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
                alertController.addAction(action)
                self.present(alertController, animated: false, completion: nil)
            }
        }else{
            //location Services off
            let alertController = UIAlertController(title: "Location Services", message: "Please always allow location services for background functions", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
        }
        
        log.info("checking time")
        self.setupTitle()
        nextLesson = 1
        //check if today have lessons
        if checkLesson.checkCurrentLesson() == true {
            if appdelegate.isInternetAvailable() != false{
                checkAttendance.checkAttendance()
                currentLesson = GlobalData.currentLesson
                if currentLesson.lecturer_id != 0 {
                    self.currentLessonRefresh()
                    
                    subjectLabel.text = currentLesson.subject! + " " + currentLesson.catalog!
                    classLabel.text = currentLesson.class_section
                    timeLabel.text = displayTime.display(time: currentLesson.start_time!) + " - " + displayTime.display(time: currentLesson.end_time!)
                    venueLabel.text = currentLesson.location
                    currentTimeLabel.textColor = UIColor.gray
                    currentTimeLabel.text = "Waiting for \nlecturer's beacon"
                    GlobalData.currentLesson = currentLesson
                    //imageView.image = #imageLiteral(resourceName: "blue-on")
                    log.info("Self.classmatesall \(GlobalData.classmates.count)")
                    //print("Current Lesson : \(GlobalData.lessonUUID)")
                    self.lecturer = GlobalData.lecturers.filter({$0.lec_id == currentLesson.lecturer_id}).first!
                    GlobalData.currentLecturerId = lecturer.lec_id!
                    GlobalData.currentLecturerMajor = lecturer.major!
                    GlobalData.currentLecturerMinor = lecturer.minor!
                    /*self.classmate = GlobalData.classmates.filter({($0.lesson_id! == currentLesson.lesson_id!)}).first!
                     print("Students  \(String(describing: self.classmate.student_id?.count))")*/
                    log.info("current lesson : \(String(describing: GlobalData.currentLesson.catalog!))")
                    log.info("My Student Id : \(UserDefaults.standard.string(forKey: "student_id")!)")
                    log.info("My Name : \(UserDefaults.standard.string(forKey: "name")!)")
                }
            }else{
                let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
        
        if appdelegate.isInternetAvailable(){
            //check if there is a new version on app store
            _ = try? self.appdelegate.isUpdateAvailable { (update, error) in
                if let error = error {
                    print(error)
                } else if let update = update {
                    print(update)
                    if update{
                        let alertController = UIAlertController(title: "Update", message: "New version is available on the app store.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                            let appID = "1298489232"
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + appID ),
                                UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        })
                        alertController.addAction(action)
                        self.present(alertController, animated: false, completion: nil)
                    }
                    
                }
            }
        }
    }
    
    private func nextLessonRefresh(){
        let nLesson = GlobalData.nextLesson
        let date = Format.Format(date: Date(), format: "HH:mm:ss")
        let start_time = Format.Format(string: nLesson.start_time!, format: "HH:mm:ss")
        let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: Format.Format(string: date, format: "HH:mm:ss"), to: start_time)
        let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - 600)
        if interval > 0 {
            let nTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(checkTime), userInfo: nil, repeats: false)
            RunLoop.main.add(nTimer, forMode: RunLoopMode.commonModes)
            
        }
        
    }
    
    private func currentLessonRefresh(){
        let cLesson = GlobalData.currentLesson
        let date = Format.Format(date: Date(), format: "HH:mm:ss")
        let start_time = Format.Format(string: cLesson.start_time!, format: "HH:mm:ss")
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
            
            if let JSON = response.result.value as? [AnyObject]{
                
                GlobalData.timetable.removeAll()
                GlobalData.lecturers.removeAll()
                
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
            
            if let code = response.response?.statusCode{
                if code == 200{
                    Alamofire.request(Constant.URLstudentlogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                        let code = response.response?.statusCode
                        spinnerIndicator.removeFromSuperview()
                        log.info("Login Status code : " + String(describing: code))
                        if code == 200{
                            if let json = response.result.value as? [String:AnyObject]{
                                UserDefaults.standard.set(json["token"], forKey: "token")
                                let status = json["status"] as? Int
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
                                self.checkTime()
                                if status != 10{
                                    Constant.change_device = true
                                }else{
                                    self.checkTime()
                                }
                            }
                        }
                    }
                }else if (code>=400) && (code<=500){
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "userFailed"), object: nil)
                }
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

