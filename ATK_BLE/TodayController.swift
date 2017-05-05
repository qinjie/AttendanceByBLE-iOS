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
    
    @IBOutlet weak var broadcast: UILabel!
    
    var lessons : [Lesson]!
    var classmate = Classmate()
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
        
        self.broadcast.text = "NOT broadcasting"
        self.broadcast.textColor = UIColor.green
        
        self.switchBtn.isOn = false
        self.switchBtn.setOn(self.switchBtn.isOn, animated: true)

        
        
        //collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)
        //  self.tableView.register(LessonCell.self, forCellReuseIdentifier: "cell")
        navigationItem.title = "Today Timetable"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        lessons = GlobalData.today
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        
        loadHistory()
        
        NotificationCenter.default.addObserver(self,selector: #selector(rload), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(syncnewdata), name: NSNotification.Name(rawValue: "updatedata"), object: nil)
        
        newDay()
        
        if (Constant.change_device){
            changeDV()
        }
        
        
        
    }
    
    func syncnewdata(){
        
       
        
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        lessons = GlobalData.today
        
        self.tableView.reloadData()
    }
    
    func changeDV(){
        
        let alert = UIAlertController(title: "NEW DEVICE", message: "You are loging in new device. Do you want to register new device?\n1. Accept: You have to wait until tomorrow to take attendance on this device.\n2. Decline: You can only view your timetable on this device.", preferredStyle: UIAlertControllerStyle.alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { action in
            
            // register new device
            
            let headers: HTTPHeaders = [
                 "Content-Type": "application/json"
            ]
            
            let thisdevice = UIDevice.current.identifierForVendor?.uuidString
            
            let parameters: [String: Any] = ["username":Constant.username,
                                             "password":Constant.password,
                                             "device_hash": thisdevice!]
       
            Alamofire.request(Constant.URLchangedevice, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                /*if let data = response.result.value{
                   print(data)
                }*/
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "Decline", style: UIAlertActionStyle.cancel, handler: { action in
            
            Constant.change_device = true
            
            
        }))
           
        self.present(alert, animated: true, completion: nil)
    }
    func rload(){
        displayMyAlertMessage(title: "Successfull Attendance", mess: "You had taken attendance for \(currentLesson.catalog!)")
    
    }
    
  
    @IBAction func checkLesson(_ sender: Any) {

        if (currentLesson != nil){
        
            self.performSegue(withIdentifier: "currentLessonSegue", sender: nil)
        
        }else{
        
            displayMyAlertMessage(title: "Check", mess: "No lesson at the moment")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier! == "currentLessonSegue"){
            // retrieve selected cell & fruit
            let atkController = segue.destination as! ATKController
            if currentLesson != nil {
                
                
                atkController.lesson = currentLesson
                atkController.uuids = self.uuid.description
            }else{
                atkController.lesson = Lesson()
            }
        }else{
            
            if let indexPath = getIndexPathForSelectedCell() {
                let x = lessons?[indexPath.item]
                let detailPage = segue.destination as! LessonDetailView
                detailPage.lesson = x!
            }
        }
        
    }

   
    func getIndexPathForSelectedCell() -> IndexPath? {
        
        var indexPath:IndexPath?
        
        if (tableView.indexPathsForSelectedRows?.count)! > 0 {
            indexPath = tableView.indexPathsForSelectedRows![0]
        }
        return indexPath
    }

    
        //    func maps(sender: UIBarButtonItem) {
    //        // Perform your custom actions
    //        // ...
    //         self.performSegue(withIdentifier: "mapSegue", sender: nil)
    //       
    //    }

    
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
        
        print("tomorrow \(String(describing: tomorrow))")
        
        let timer = Timer(fireAt: tomorrow!, interval: 0, target: self, selector: #selector(newDay), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        currentTimeStr = dateFormatter.string(from: today)
        
        nextLesson = GlobalData.today.first(where: {($0.start_time! <= currentTimeStr) && ($0.end_time! > currentTimeStr)})
        
        updateLesson()
    }

    func updateLesson(){
        
        today = Date()
        
        currentLesson = nextLesson
        
        dateFormatter.dateFormat = "HH:mm:ss"
        
        currentTimeStr = dateFormatter.string(from: today)
        
        print("current time \(currentTimeStr)")
        nextLesson = GlobalData.today.first(where: {$0.start_time! > currentTimeStr})
        
        if (currentLesson != nil){
            print("Current lesson id \(String(describing: currentLesson.lesson_id))")
            self.classmate = GlobalData.classmates.first(where : {($0.lesson_id! == currentLesson.lesson_id!)})!
            print("Self.classmates \(String(describing: self.classmate.student_id?.count))")
            GlobalData.currentLesson = self.currentLesson
            
            ATK()
        }
        
        if (nextLesson != nil){
            print("next Lesson id \(String(describing: nextLesson.lesson_id))")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let x = GlobalData.currentDateStr + " " + nextLesson.start_time!
            
            let y = dateFormatter.date(from: x)
            
            let date = y?.addingTimeInterval(10)
            let timer = Timer(fireAt: date!, interval: 0, target: self, selector: #selector(updateLesson), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            
        }else{
            
        }
        
        
        
        
      //  ATK()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
    }
    
    
    func ATK(){
        
        detectClassmate()
        // broadcasting 2 times, 30 seconds / 1 time
        var rand = 1 + Int(arc4random_uniform(3))
        var x = rand * 60
        var date = Date().addingTimeInterval(TimeInterval(x))
        print("date \(date)")
        var timer2 = Timer(fireAt: date, interval: 0, target: self, selector: #selector(broadcasting), userInfo: nil, repeats: false)
        
        RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)

        rand = 5 + Int(arc4random_uniform(3))
        x = rand * 60
        date = Date().addingTimeInterval(TimeInterval(x))
        print(date)
        timer2 = Timer(fireAt: date, interval: 0, target: self, selector: #selector(broadcasting), userInfo: nil, repeats: false)
        date = Date().addingTimeInterval(TimeInterval(x+30))

        RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)
     
        
        
    }
    
    func detectClassmate(){
        
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[currentLesson.lesson_id!]!) as UUID?
        print("Current Lesson : \(uuid)")
        
        if ((classmate.student_id?.count)! > 20){
            for i in 0 ..< 20 {
                
               let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(classmate.major![i]) as CLBeaconMajorValue, minor: UInt16((classmate.minor?[i])!) as CLBeaconMinorValue, identifier: (classmate.student_id?[i].description)!)
                
               locationManager.startMonitoring(for: newRegion)
            }
        }else{
            for i in 0 ..< (classmate.student_id?.count)!  {
                
                let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(classmate.major![i]) as CLBeaconMajorValue, minor: UInt16((classmate.minor?[i])!) as CLBeaconMinorValue, identifier: (classmate.student_id?[i].description)!)
                
                locationManager.startMonitoring(for: newRegion)
            }

        }
        
    }
    
    func getCurrentLesson(){
        
       // let today = Date()
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
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[id]!) as UUID?
        
        let lectureRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(lecturerMajor) as CLBeaconMajorValue, minor: UInt16(lecturerMinor) as CLBeaconMinorValue, identifier: GlobalData.currentLecturerId.description)
        
        self.locationManager.startMonitoring(for: lectureRegion)
        
        broadcasting()
        
//        let newRegion = CLBeaconRegion(proximityUUID: uuid , major: UInt16(Constant.major) as CLBeaconMajorValue, minor: UInt16(Constant.minor) as CLBeaconMinorValue, identifier: Constant.username)
    }
    
    
    
    func turnoffbroad(){
        bluetoothPeripheralManager.stopAdvertising()
        isBroadcasting = false
        self.broadcast.text = "NOT broadcasting"
        self.broadcast.textColor = UIColor.green
        self.switchBtn.isOn = false
        self.switchBtn.setOn(self.switchBtn.isOn, animated: true)
    }
    
    func broadcasting(){
        print("NOTI")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openapp"), object: nil)
        
        if !isBroadcasting {
            
            if bluetoothPeripheralManager.state == .poweredOn {
                
                let major = UInt16(Constant.major) as CLBeaconMajorValue
                let minor = UInt16(Constant.minor) as CLBeaconMinorValue,
                
                beaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, major: major, minor: minor, identifier: Constant.username)
                
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : Any])
             
                isBroadcasting = true
                self.broadcast.text = "Is broadcasting"
                self.broadcast.textColor = UIColor.red
                self.switchBtn.isOn = true
                self.switchBtn.setOn(self.switchBtn.isOn, animated: true)
                
                let date = Date().addingTimeInterval(TimeInterval(30))
                
                let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(turnoffbroad), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            }
            else{
                
                self.broadcast.text = "NOT broadcasting"
                self.broadcast.textColor = UIColor.green

                let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " ATK would like to turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { action in
                    self.turnOnBlt()
                    self.turnOnBlt()
                    self.broadcasting()
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

    @IBOutlet weak var switchBtn: UISwitch!
    @IBAction func broadbyHand(_ sender: Any) {
        if (self.switchBtn.isOn){
            if (self.currentLesson == nil){
                displayMyAlertMessage(title: "Notice", mess: "No lesson at the moment. You can only broadcast in lesson time.")
                self.switchBtn.isOn = !self.switchBtn.isOn
                self.switchBtn.setOn(self.switchBtn.isOn, animated: true)
            }else{
              
                broadcasting() 
            }
            
        }else{
            
            turnoffbroad()
            
        }
    }
    
    func turnOnBlt(){
        let bluetoothManager = BluetoothManagerHandler.sharedInstance()
        
        bluetoothManager?.setPower(true)
    }

//    @IBAction func checkLesson(_ sender: Any) {
//        
//        self.performSegue(withIdentifier: "currentLessonSegue", sender: nil)
//    }
    
    
    
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
    
            //print("count \(lessons.count)")
            return lessons.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120.0;
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
        
        print(cell.lesson?.catalog)
        
        self.performSegue(withIdentifier: "lessonDetailSegue", sender: nil)
        
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
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //print("@1: did enter region!!!")
        
        if (region is CLBeaconRegion) {
            
            print("@2: did enter region!!!  \(region.identifier)" )
            
            //   noti(content: "ENTER  " + region.identifier)
        }
    }
    
    func loadattendance(){
        print("load att ")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token
            // "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLattendance, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let JSON = response.result.value as? [[String:Any]]{
                for json in JSON{
                    let id = (json["lesson_date_id"] as? Int)!
                    GlobalData.attendance.append(id)
                }
            }
            print("load atk success")
        }
    }
    
    func loadHistory(){
        let token = UserDefaults.standard.string(forKey: "token")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!
            // "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLhistory, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            /*let data = response.result.value
            print(data)*/
            if let JSON = response.result.value as? [[String:AnyObject]]{
                
                for json in JSON {
                    let x = History()
                    x.name = json["lesson_name"] as! String
                    x.total = json["total"] as! Int
                    x.absent = json["absented"] as! Int
                    x.present = json["presented"] as! Int
                    GlobalData.history.append(x)
                }
            }
        }
    }
}
