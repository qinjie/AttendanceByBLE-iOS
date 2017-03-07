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

    var currentday : String!
    var currenttime : String!
    var currentLesson : Lesson!
    
    var isBroadcasting = false
    let locationManager = CLLocationManager()
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    var uuid : UUID!
    var dataDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)
        //  self.tableView.register(LessonCell.self, forCellReuseIdentifier: "cell")
        navigationItem.title = "Today Timetable"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        let today = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let y = dateFormatter.string(from: today)
        
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == y})
        
        lessons = GlobalData.today
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        start()
        
        
    }
    
    func start(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!
             "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLcurrentLesson, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            let data = response.result.value
            print(data)
            if let JSON = response.result.value as? [String:AnyObject]{
                
                print(JSON)
                let lesson_id = (JSON["id"] as? Int)!
                
                self.startMonitorLesson(id: lesson_id)
            }
        }
        
    }
    
    func startMonitorLesson(id : Int){
        
        currentLesson = GlobalData.today.first(where: {$0.lesson_id == id})
        
        // start monitor other vitual beacon
        uuid = NSUUID(uuidString: GlobalData.lessonUUID[id]!) as! UUID
        
        let newRegion = CLBeaconRegion(proximityUUID: uuid, identifier: currentLesson.name!)
        
        self.locationManager.startMonitoring(for: newRegion)
        
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
    
    
    
    
    // MARK: CBPeripheralManagerDelegate method implementation
    //
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
