//
//  TodayController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//
import CoreBluetooth
import CoreLocation
import Alamofire
import UIKit

class TodayController: UITableViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate{
    
    fileprivate let cellId = "cell"
    
    var lessons : [Lesson]!
    var classmate = [BeaconUser]()
    var nextLesson : Lesson!
    var currentLesson : Lesson!
    
    var isBroadcasting = false
    let locationManager = CLLocationManager()
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    var uuid : UUID!
    var dataDictionary = NSDictionary()
    
    var lecturerMajor : Int!
    var lecturerMinor : Int!
    var lecturerName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)
        //  self.tableView.register(LessonCell.self, forCellReuseIdentifier: "cell")
        navigationItem.title = "Today Timetable"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        lessons = GlobalData.today
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        newDay()
        
        
    }
    
    var today = Date()
    var dateFormatter = DateFormatter()
    var currentTimeStr = ""
    
    func newDay(){
        
        today = Date()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        GlobalData.currentDateStr = dateFormatter.string(from: today)
        
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        
        let tomorrowStr = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: today)!) + " 07:00:00"
        
        print(tomorrowStr)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let tomorrow = dateFormatter.date(from: tomorrowStr)
        
        print("tomorrow \(tomorrow)")
        
        let timer = Timer(fireAt: tomorrow!, interval: 0, target: self, selector: #selector(newDay), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        currentTimeStr = dateFormatter.string(from: today)
        
        nextLesson = GlobalData.today.first(where: {($0.start_time! <= currentTimeStr) && ($0.end_time! > currentTimeStr)})
        
        updateLesson()
    }

    func updateLesson(){
        
        currentLesson = nextLesson
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        currentTimeStr = dateFormatter.string(from: today)
        
        nextLesson = GlobalData.today.first(where: {$0.start_time! > currentTimeStr})
        
        if (currentLesson != nil){
            
            ATK()
           
            if (nextLesson != nil){
                
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let x = GlobalData.currentDateStr + " " + nextLesson.start_time!
                
                let y = dateFormatter.date(from: x)
                
                let date = y?.addingTimeInterval(10)
                let timer = Timer(fireAt: date!, interval: 0, target: self, selector: #selector(updateLesson), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)

            }else{
            
            }
            
            
        }else{
            
        }
        
      //  ATK()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
    }
    
    
    func ATK(){
        
        // get classmate major minor
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = ["lesson_id": 29]
        
        Alamofire.request(Constant.URLclassmate, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let JSON = response.result.value as? [[String: AnyObject]]{
                
                print(JSON)
                for json in JSON{
                    let x = BeaconUser()
                    x.id = json["user_id"] as! Int
                    
                    if (x.id != Constant.user_id){
                        
                        if let beacon = json["beacon_user"] as? [String: AnyObject]{
                            x.major = beacon["major"] as! Int
                            x.minor = beacon["minor"] as! Int
                            self.classmate.append(x)
                        }
                        
                    }
                    
                }
                self.detectClassmate()
               
            }else {
                print("Parse error")
                return
            }
        
        }
        
    }
    
    func detectClassmate(){
        
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!) as! UUID
        print("Current Lesson : \(uuid)")
        
        if (classmate.count > 20){
            for i in 0 ..< 20 {
                
               let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(classmate[i].major) as CLBeaconMajorValue, minor: UInt16(classmate[i].minor) as CLBeaconMinorValue, identifier: classmate[i].id.description)
                
               locationManager.startMonitoring(for: newRegion)
            }
        }else{
            for cm in classmate {
                
                let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(cm.major) as CLBeaconMajorValue, minor: UInt16(cm.minor) as CLBeaconMinorValue, identifier: cm.id.description)
                
                locationManager.startMonitoring(for: newRegion)
            }
        }
        
    }
    
    func getCurrentLesson(){
        
        let today = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //   let y = dateFormatter.string(from: today)
        let x = "2017-03-09 09:57:00"
        let y = dateFormatter.date(from: x)
        
        
        //        for lesson in GlobalData.today{
        //            if (lesson.start_time! > y){
        //                print(lesson.start_time)
        //            }
        //        }
        
        let date = y?.addingTimeInterval(9.9)
        let timer = Timer(fireAt: date!, interval: 0, target: self, selector: #selector(printL), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        //        self.updateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.printL), userInfo: nil, repeats: true)
        
    }
    var updateTimer: Timer?
    
    func printL(){
        print("TEST")
        
    
    }
    
    func startMonitorLesson(id : Int){
        
        currentLesson = GlobalData.today.first(where: {$0.lesson_id == id})
        
        // start monitor other vitual beacon
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[id]!) as! UUID
        
        let newRegion = CLBeaconRegion(proximityUUID: uuid, identifier: currentLesson.name!)
        let lectureRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(lecturerMajor) as CLBeaconMajorValue, minor: UInt16(lecturerMinor) as CLBeaconMinorValue, identifier: GlobalData.currentLecturerId.description)
        
        self.locationManager.startMonitoring(for: newRegion)
        self.locationManager.startMonitoring(for: lectureRegion)
        
        broadcasting()
        
//        let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(Constant.major) as CLBeaconMajorValue, minor: UInt16(Constant.minor) as CLBeaconMinorValue, identifier: Constant.username)
    }
    
    
    
    func broadcasting(){
        
        if !isBroadcasting {
            
            if bluetoothPeripheralManager.state == .poweredOn {
                
                let major = UInt16(Constant.major) as CLBeaconMajorValue
                let minor = UInt16(Constant.minor) as CLBeaconMinorValue,
                
                beaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, major: major, minor: minor, identifier: Constant.username)
                
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : Any])
             
                isBroadcasting = true
            }
            else{
                let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " ATK would like to turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { action in
                    self.turnOnBlt()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
//                bluetoothPeripheralManager.stopAdvertising()
//                
//                
//                //                txtMajor.isEnabled = true
//                //                txtMinor.isEnabled = true
//                
//                
//                isBroadcasting = false
            }
            
        }

        
    }

    func turnOnBlt(){
        let bluetoothManager = BluetoothManagerHandler.sharedInstance()
        
        bluetoothManager?.setPower(true)
    }

    @IBAction func checkLesson(_ sender: Any) {
        self.performSegue(withIdentifier: "currentLessonSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailPage = segue.destination as! ATKController
        
        detailPage.currentLesson = self.currentLesson
     
        
    }
    
    
    // MARK: CBPeripheralManagerDelegate method implementation

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "Bluetooth Status: \n Turned On"
            
        case .poweredOff:
            if isBroadcasting {
             //   switchBroadcastingState(self)
            }
            statusMessage = "Bluetooth Status: \n Turned Off"
            
        case .resetting:
            statusMessage = "Bluetooth Status: \n Resetting"
            
        case .unauthorized:
            statusMessage = "Bluetooth Status: \n Not Authorized"
            
        case .unsupported:
            statusMessage = "Bluetooth Status: \n Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: \n Unknown"
        }
        
      
    }

    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
            print("count \(lessons.count)")
            return lessons.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        cell.lesson = lessons[indexPath.row]
        //        // Configure the cell...
        //        let lessonInDay = GlobalData.timetable.filter({$0.weekday == wdayInt[indexPath.section]})
        //
        //        let lesson = lessonInDay[indexPath.row]
        //        cell.lesson = lesson
        //   print("cell \(cell.subjectLabel.text)")
        //        cell.idLabel.text = lesson.lesson_id?.description
        //        cell.start_time.text = lesson.start_time
        //        cell.end_time.text = lesson.end_time
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell else { return }
        
        print(cell.lesson?.name)
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
            print(" -____- Inside \(region.identifier)");
            
            noti(content: "found  " + region.identifier)
     
            
        //report(region: CLRegion)
        case .outside:
            print(" -____- Outside");
            
            // noti(content: "OUTSIDE  " + region.identifier)
            
        case .unknown:
            print(" -____- Unknown");
        default:
            print(" -____-  default");
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //print("@1: did enter region!!!")
        
        if (region is CLBeaconRegion) {
            
            print("@2: did enter region!!!  \(region.identifier)" )
            
            //   noti(content: "ENTER  " + region.identifier)
        }
    }
}
