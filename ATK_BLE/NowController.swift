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
    
    let lecturerMajor: Int! = 0
    let lecturerMinor: Int! = 0
    var uuid: UUID!
    var dataDictionary = NSDictionary()
    var classmate = Classmate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()  // to receive local notification from other view
        checkDevice()   // check if this is new device
        GlobalData.timetable.sort(by: {$0.start_time! < $1.start_time!})
        HistoryBrain.arrangeHistory()
        broadcastLabel.isHidden = true
        setupImageView()
        
        locationManager.delegate = self
        bluetoothManager.delegate = self
        bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        
        checkTime()
        setupTimer()    //For every lesson before 10 mins
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func setupTimer(){
        
        var date = Format.Format(date: Date(), format: "HH:mm:ss")
        let upcomingLesson = GlobalData.today.filter({$0.start_time! > date})
        for i in upcomingLesson{
            date = Format.Format(date: Date(), format: "HH:mm:ss")
            let start_time = Format.Format(string: i.start_time!, format: "HH:mm:ss")
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: Format.Format(string: date, format: "HH:mm:ss"), to: start_time)
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - 600)
            if interval > 0 {
                let notificationContent = notification.notiContent(title: "Upcoming lesson", body: "\(String(describing: i.catalog!)) \(String(describing: i.class_section!)) \(String(describing: i.location!))")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: String(describing:i.ldateid))
            }
            
        }
        
    }
    
    private func addObservers(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(success), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(changeLabel), name: NSNotification.Name(rawValue: "taken"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(enableImageView), name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
        
    }
    
    @objc func enableImageView(){
        imageView.isUserInteractionEnabled = true
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

            print("Changed device result: " + String(describing: response.response!.statusCode))

        })
    }
    
    private func stopLiao(){
        print("Stop Advertising!!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func userInfobutton(_ sender: UIButton) {
        
        showUserInfo()
        
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
        self.currentTimeLabel.text = "You have taken attendance \nfor \(self.currentLesson.catalog!)"
        self.currentTimeLabel.textColor = UIColor.green
        
    }
    
    @objc private func broadcastSignal() {
        if imageView.isAnimating{
            imageView.stopAnimating()
            imageView.image = #imageLiteral(resourceName: "bluetooth_on")
            //bluetoothManager.stopAdvertising()
            return
        }
        if currentLesson != nil {
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
    
    func stopBroadcast() {
        bluetoothManager.stopAdvertising()
        self.imageView.stopAnimating()
    }
    
    @objc func detectClassmate() {
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
        print("Current lesson: \(uuid)")
        if ((classmate.student_id?.count)! == 0)
        {
            print("classmate is 0")
        }
        else if ((classmate.student_id?.count)! > 20){
            print("more than 20")
            for i in 0 ..< 20 {
                let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(classmate.major![i]) as CLBeaconMajorValue, minor: UInt16((classmate.minor?[i])!) as CLBeaconMinorValue, identifier: (classmate.student_id?[i].description)!)
                locationManager.startMonitoring(for: newRegion)
            }
        }
        else{
            print("less than 20")
            for i in 0 ..< (classmate.student_id?.count)!  {
                let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(classmate.major![i]) as CLBeaconMajorValue, minor: UInt16((classmate.minor?[i])!) as CLBeaconMinorValue, identifier: (classmate.student_id?[i].description)!)
                
                locationManager.startMonitoring(for: newRegion)
            }
            
        }
    }
    
    private func detectLecturer() {
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
        let lecturerRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(lecturerMajor)as CLBeaconMajorValue, minor: UInt16(lecturerMinor)as CLBeaconMinorValue, identifier: GlobalData.currentLecturerId.description)
        locationManager.startMonitoring(for: lecturerRegion)
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
        print(status)
    }
    
    func broadcastTime(time:Int) {
        let rand = time + Int(arc4random_uniform(3))
        let x = rand * 60
        let date = Date().addingTimeInterval(TimeInterval(x))
        print("date \(date)")
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(broadcast), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    func broadcast() {
        
        if bluetoothManager.state == .poweredOn {
            print("broadcasting")
            let major = UInt16(Int(UserDefaults.standard.string(forKey: "major")!)!)as CLBeaconMajorValue
            let minor = UInt16(Int(UserDefaults.standard.string(forKey: "minor")!)!)as CLBeaconMinorValue
            uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "\(String(describing: UserDefaults.standard.string(forKey: "student_id")!))")
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
            
            let date = Date().addingTimeInterval(TimeInterval(30))
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
        let content = notification.notiContent(title: "successfull", body: "You have successfully taken attendance")
        notification.addNotification(trigger: trigger, content: content, identifier: "abc")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        print("Stop monitoring \(region.identifier) region")
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
            print("did enter region!!! \(region.identifier)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("fg did determine state!!!!!")
        switch(state) {
        case .inside:print("fg inside\(region.identifier)")
        case .outside:print("fg outside\(region.identifier)")
        case .unknown:print("fg unknown\(region.identifier)")
        }
    }
    
    @objc private func checkTime(){
        self.setupTitle()
        today = Date()
        GlobalData.currentDateStr = Format.Format(date: today, format: "yyyy-MM-dd")
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        nextLesson = 1
        //check if today have lessons
        if GlobalData.today.count > 0 {
            today.addTimeInterval(300)
            currentTimeStr = Format.Format(date: today, format: "HH:mm:ss")
            currentLesson = GlobalData.today.first(where: {$0.start_time!<=currentTimeStr && $0.end_time!>=currentTimeStr})
            //check current have lessons?
            if currentLesson != nil {
                subjectLabel.text = currentLesson.subject! + " " + currentLesson.catalog!
                classLabel.text = currentLesson.class_section
                timeLabel.text = displayTime.display(time: currentLesson.start_time!) + " - " + displayTime.display(time: currentLesson.end_time!)
                venueLabel.text = currentLesson.venueName
                currentTimeLabel.textColor = UIColor.gray
                currentTimeLabel.text = "Waiting for \nbeacons from classmates"
                GlobalData.currentLesson = currentLesson
                imageView.image = #imageLiteral(resourceName: "bluetooth_on")

                checkAttendance.checkAttendance()
                
                
                print("Self.classmatesall \(GlobalData.classmates.count)!")
                //print("Current Lesson : \(GlobalData.lessonUUID)")
                self.classmate = GlobalData.classmates.filter({($0.lesson_id! == currentLesson.lesson_id!)}).first!
                
                print("Students  \(String(describing: self.classmate.student_id?.count))")
                print("\(String(describing: GlobalData.currentLesson.catalog))")
                print(UserDefaults.standard.string(forKey: "student_id")!)
                if GlobalData.detectClassmateObserver != true{
                    NotificationCenter.default.addObserver(self, selector: #selector(detectClassmate), name: NSNotification.Name(rawValue: "detect classmate"), object: nil)
                    GlobalData.detectClassmateObserver = true
                }
                
            }else{
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
                    subjectLabel.text = nLesson.subject! + " " + nLesson.catalog!
                    classLabel.text = nLesson.class_section
                    timeLabel.text = displayTime.display(time: nLesson.start_time!) + " - " + displayTime.display(time: nLesson.end_time!)
                    venueLabel.text = nLesson.venueName
                    currentTimeLabel.text = "not yet time \ntry again after \(hr):\(min)"
                }else{
                    GlobalData.currentLesson.ldateid = nil
                    self.nextLesson = nil
                    
                }
            }
        }
        updateLabels()
    }
    func changeLabel() {
        self.currentTimeLabel.text = "You have taken attendance \nfor \(self.currentLesson.catalog!)"
        self.currentTimeLabel.textColor = UIColor.green
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
            imageView.image = #imageLiteral(resourceName: "bluetooth_off")
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
            
        }
    }
    
    private func checkUserInBackGround(){
        
        let this_device = UIDevice.current.identifierForVendor?.uuidString
        let parameters:[String:Any] = [
            "username" : UserDefaults.standard.string(forKey: "username")!,
            "password" : UserDefaults.standard.string(forKey: "password")!,
            "device_hash" : this_device!
        ]
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        self.view.addSubview(spinnerIndicator)
        Alamofire.request(Constant.URLstudentlogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            let code = response.response?.statusCode
            spinnerIndicator.removeFromSuperview()
            if code == 200{
                if let json = response.result.value as? [String:AnyObject]{
                    UserDefaults.standard.set(json["token"], forKey: "token")
                    let status = json["status"] as? Int
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enable imageView"), object: nil)
                    if status != 10{
                        Constant.change_device = true
                    }else{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"detect classmate"), object: nil)
                    }
                }
            }
        }
        
        let token = UserDefaults.standard.string(forKey: "token")!
        let headersTimetable:HTTPHeaders = [
            "Authorization" : "Bearer " + token
        ]
        
        DispatchQueue.global().async {
            Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersTimetable).responseJSON { (response:DataResponse) in
                let code = response.response?.statusCode
                if code == 200{
                }else{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "userFailed"), object: nil)
                }
            }
        }
    }
    
    private func showUserInfo(){
        let username = UserDefaults.standard.string(forKey: "username")!
        let card = UserDefaults.standard.string(forKey: "card")!
        if(self.presentedViewController == nil) {
            displayAlert(title: "Name: \(username)", message: "Student id: \(card)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pop" {
            let dest = segue.destination
            if let pop = dest.popoverPresentationController {
                pop.delegate = self
                         }
        }
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

