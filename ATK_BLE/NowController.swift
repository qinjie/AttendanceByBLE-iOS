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
    var button = UIButton()
    var dateFormatter = DateFormatter()
    var currentTimeStr = ""
    var currentLesson:Lesson!
    var nextLesson:Lesson!
    var timer:Timer?
    
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var isGrantedNotificationAccess = false
    
    let lecturerMajor: Int! = 0
    let lecturerMinor: Int! = 0
    var uuid: UUID!
    var dataDictionary = NSDictionary()
    var classmate = Classmate()

    @IBAction func userInfobutton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "pop", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pop" {
            let dest = segue.destination
            if let pop = dest.popoverPresentationController {
                pop.delegate = self
                if(self.presentedViewController == nil) {
                    displayAlert(title: "Info \(String(describing: UserDefaults.standard.string(forKey: "username")!))", message: "ll")
                }            }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        broadcastLabel.isHidden = true
        setupImageView()
        checkUserInBackGround()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        bluetoothManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        checkTime()
        NotificationCenter.default.addObserver(self,selector: #selector(success), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)    }
    
    override func viewWillAppear(_ animated: Bool) {
        bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupImageView(){
        
        imageView.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(broadcastSignal))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
        
    }
    func success() {
        self.currentTimeLabel.text = "You have taken attendance \nfor \(self.currentLesson.catalog!)"
        self.currentTimeLabel.textColor = UIColor.green
        displayAlert(title: "Successful", message: "You have taken attendance for\(currentLesson.catalog!)")
    }
    
    @objc func broadcastSignal() {
        if imageView.isAnimating{
            imageView.stopAnimating()
            imageView.image = #imageLiteral(resourceName: "bt_on")
            return
        }
        if currentLesson != nil {
            imageView.animationImages = [
                #imageLiteral(resourceName: "transmit_1"),
                #imageLiteral(resourceName: "transmit_2"),
                #imageLiteral(resourceName: "transmit_3")
            ]
            imageView.animationDuration = 0.5
            imageView.startAnimating()
            broadcast()
        }
        else{
            updateLabels()
        }
        
    }
    func turnOnBlt() {
        //let bluetoothManager = BluetoothManagerHandler.sharedInstance()
        //bluetoothManager?.setPower(true)
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        //app.openURL(url!)
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    func detectClassmate() {
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
    func detectLecturer() {
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
    func broadcast() {
        if bluetoothManager.state == .poweredOn {
            /*let major = UInt16(UserDefaults.standard.string(forKey: "major")!)as! CLBeaconMajorValue
            let minor = UInt16(UserDefaults.standard.string(forKey: "minor")!)as! CLBeaconMinorValue */
            let major = UInt16(Constant.major)as CLBeaconMajorValue
            let minor = UInt16(Constant.minor)as CLBeaconMinorValue
           uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!)as UUID?
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "\(String(describing: UserDefaults.standard.string(forKey: "student_id")!))")
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            //bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
            bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
        }
        else {
            let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " AME would like to turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { action in
                self.turnOnBlt()
                self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }        }
    }
    func testSendNoti() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
        let content = notiContent(title: "successfull", body: "You have successfully taken attendance")
        addNotification(trigger: trigger, content: content, identifier: "a")            }    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring \(region.identifier) region")
    }
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        print("Stop monitoring \(region.identifier) region")
    }
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert,.badge,.sound])
}

public func checkAttandance() -> Bool {
    var result = false
    let token = UserDefaults.standard.string(forKey: "token")
    let header:HTTPHeaders = [
        "Authorization" : "Bearer " + token!
    ]
    // let parameter: [String:Any] = ["lesson-date-id":GlobalData.currentLesson.ldateid!]
    let parameter:Parameters = ["lesson_date_id":GlobalData.currentLesson.ldateid!]
    Alamofire.request(Constant.URLcheckAttandance,method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: { (response:DataResponse) in
        if let JSON = response.result.value as? Int {
            print("////////(JSON)")
            if(JSON >= 0) {
                result = true
            }
            else {
                result = false
                print(JSON)
            }            }
    })
    return result
    
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }

    
    private func checkTime(){
        today = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        GlobalData.currentDateStr = dateFormatter.string(from: today)
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        //print("Today : " + String(GlobalData.today.count))
        
        //check if today have lessons
        if GlobalData.today.count > 0 {
            
            dateFormatter.dateFormat = "HH:mm:ss"
            currentTimeStr = dateFormatter.string(from: today)
            currentLesson = GlobalData.today.first(where: {$0.start_time!<currentTimeStr && $0.end_time!>currentTimeStr})
            //check current have lessons?
            if currentLesson != nil {
                subjectLabel.text = currentLesson.subject! + " " + currentLesson.catalog!
                classLabel.text = currentLesson.class_section
                timeLabel.text = displayTime.display(time: currentLesson.start_time!) + " - " + displayTime.display(time: currentLesson.end_time!)
                venueLabel.text = currentLesson.venueName
                currentTimeLabel.textColor = UIColor.gray
                currentTimeLabel.text = "Waiting for \nbeacons from classmates"
                GlobalData.currentLesson = currentLesson
                imageView.image = #imageLiteral(resourceName: "bt_on")
                if(checkAttandance()) {
                    let value = checkAttandance()
                    print(value)
                    
                    self.currentTimeLabel.text = "You have taken attendance \nfor \(self.currentLesson.catalog!)"
                    self.currentTimeLabel.textColor = UIColor.green
                }
                print("Self.classmatesall \(GlobalData.classmates.count)!")
                print("Current Lesson : \(GlobalData.lessonUUID)")
                self.classmate = GlobalData.classmates.first(where : {($0.lesson_id! == currentLesson.lesson_id!)})!
                print("Self.classmates \(String(describing: self.classmate.student_id?.count))")
                print("\(String(describing: GlobalData.currentLesson.catalog))")
                print(UserDefaults.standard.string(forKey: "student_id")!)
                detectClassmate()
            }else{
                if let nextLesson = GlobalData.today.first(where: {$0.start_time!>currentTimeStr}){
                    //Estimate the next lesson time
                    let time = nextLesson.start_time?.components(separatedBy: ":")
                    var hour:Int!
                    var minute:Int!
                    hour = Int((time?[0])!)
                    minute = Int((time?[1])!)
                    let totalSecond = hour*3600 + minute*60 - 300
                    let hr = totalSecond/3600
                    let min = (totalSecond%3600)/60
                    subjectLabel.text = nextLesson.subject! + " " + nextLesson.catalog!
                    classLabel.text = nextLesson.class_section
                    timeLabel.text = displayTime.display(time: nextLesson.start_time!) + " - " + displayTime.display(time: nextLesson.end_time!)
                    venueLabel.text = nextLesson.venueName
                    currentTimeLabel.text = "not yet time \ntry again after \(hr):\(min)"
                }
            }
        }
        updateLabels()
    }
    
    private func updateLabels(){
        
        if GlobalData.today.count == 0{
            
            subjectLabel.isHidden = true
            classLabel.isHidden = true
            timeLabel.isHidden = true
            noLessonLabel.isHidden = false
            venueLabel.isHidden = true
            currentTimeLabel.isHidden = true
            imageView.isHidden = true
            broadcastLabel.isHidden = true
            
        }else if currentLesson == nil{
            currentTimeLabel.textColor = UIColor.gray
            imageView.image = #imageLiteral(resourceName: "bt_off")
            broadcastLabel.textColor = UIColor.gray
        }
    }
    
    private func checkUserInBackGround(){
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
