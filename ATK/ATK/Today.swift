//
//  Today2ViewController.swift
//  ATKdemo
//
//  Created by xuhelios on 12/9/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import CoreLocation
import QuartzCore
import CoreBluetooth
import Alamofire


class Today: UICollectionViewController, UICollectionViewDelegateFlowLayout,  CLLocationManagerDelegate, CBPeripheralManagerDelegate
    {
    
    let venueMajor = "58949"
    
    var foundVenue = false
    
    var isSent = false
    
    var currentIndex : IndexPath = []
    
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    var isSearchingForBeacons = false
    
    var locationManager: CLLocationManager!
    
    var foundBeacon: [CLBeacon]!
    
    var lastProximity: CLProximity! = CLProximity.unknown
    
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    var lessons : [Lesson]?
    
    fileprivate let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.collectionView!.reloadData()
        
    }
    func loadData(){
        
        let today = NSDate()
        
        var formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        var todayStr = formatter.string(from: today as Date);
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
            request.returnsObjectsAsFaults = false
            
            do {
                lessons = try! context.fetch(request) as! [Lesson]
                print("Lessoncount \(lessons?.count)")
            }catch{
                fatalError("Failed to fetch \(error)")
            }
            
            lessons = lessons?.filter{ $0.lDate == todayStr }
            lessons = lessons?.sorted(by: {$0.sTime!.compare($1.sTime! as String) == .orderedAscending})
        }
        
       
        
    }
    
        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            var statusMessage = ""
    
            switch peripheral.state {
            case .poweredOn:
                statusMessage = "Bluetooth Status: \n Turned On"
    
            case .poweredOff:
    //            if isBroadcasting {
    //          //      switchBroadcastingState(self)
    //            }
                statusMessage = "Bluetooth Status: \n Turned Off"
                self.displayMyAlertMessage(mess: "PLEASE TURN ON BLUETOOTH")
                
            case .resetting:
                statusMessage = "Bluetooth Status: \n Resetting"
    
            case .unauthorized:
                statusMessage = "Bluetooth Status: \n Not Authorized"
    
            case .unsupported:
                statusMessage = "Bluetooth Status: \n Not Supported"
    
            default:
                statusMessage = "Bluetooth Status: \n Unknown"
            }
            print("\(statusMessage)")
           // lblBTStatus.text = statusMessage
        }
    
    
    // send information of 2 classmates you detected to server
    // if it sends successfully, you will take attendance successfully
    
    
    func broadcasting(){
        
        if bluetoothPeripheralManager.state == .poweredOn {
            
            print("Hello")
            
            let uuid = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
            
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, major: 9, minor: 7, identifier: "com.xuhelios.beaconpop")
            
            var dataDictionary = NSDictionary()
            
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            
            bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : Any])
    
          //  isBroadcasting = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupData()
        self.loadData()
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
        }

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
       // self.navigationController!.popViewController(animated: true)!
        navigationItem.title = "Today"
    
        //collectionView?.backgroundView.imi  .image = UIImage(named: "todaybg")
        //collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "todaybg")!)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = lessons?.count {
      
                return count
  
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LessonCell
        if let lesson = lessons?[indexPath.item] {
            cell.lesson = lesson
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      //  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LessonCell
        currentIndex = indexPath
     //   print ( currentIndex)
        if let lesson = lessons?[indexPath.item] {
            // cell.lesson = lesson
           // print("Venue \(lesson.venue?.name)")
            print("Lesson Date \(lesson.lDate)")
            print("Lesson DateId \(lesson.lDateId)")
            print("Lesson Id \(lesson.id)")
            
            if (lesson.st == 0){ // have taken attendance already
                 displayMyAlertMessage(mess: "It had taken attendance already")
            }else{
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
               // dateFormatter.dateFormat = "HH-mm-ss"
                dateFormatter.timeZone = NSTimeZone(name: "UTC+08:00") as TimeZone!
                
                let calendar = NSCalendar.current

                let lessonTimeString = lesson.lDate! + " " + lesson.sTime!
            //    let lessonTimeString = "2017-01-04 " + lesson.sTime!
                
                let lessonTime = dateFormatter.date(from: lessonTimeString)
                
               // print("stime after converting \(lessonTime)")
                
                let timeA = calendar.date(byAdding: .minute, value: -15, to: lessonTime! as Date)
                
              //  print("sTime timeA \(timeA)")
                
                let timeB = calendar.date(byAdding: .minute, value: 15, to: lessonTime! as Date) 
                
                //print("sTime timeB \(timeB)")
             
                let currentTime = NSDate()
         
             //   print("stime current \(currentTime)")
                
                if (currentTime.compare(timeA!) == .orderedAscending){
                    
                  //  displayMyAlertMessage(mess: "It is so EARLY to take attendance!!")
                    
                }else if (currentTime.compare(timeB!) == .orderedDescending){
                    
                //    displayMyAlertMessage(mess: "Cannot take attendance anymore!!")
                    
                }else{
                    
//                    print("sTime The two dates are the same")
//                    bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//                    
//                    
//                    locationManager = CLLocationManager()
//                    
//                    //   let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
//                    locationManager.delegate = self
//                    if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
//                        locationManager.requestWhenInUseAuthorization()
//                    }
                    
                }
                bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
                
                
                locationManager = CLLocationManager()
                
                //   let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
                locationManager.delegate = self
                if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
                    locationManager.requestWhenInUseAuthorization()
                }
                locationManager.startRangingBeacons(in: region)


            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        //will be edited
        // knowBeacons after found venue are the virtual beacon of the other student devices
       // print("Hello")
        
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        
        print("count  \(knownBeacons.count)")
        for beacon in knownBeacons{
            
            var x = beacon.major
            var y = beacon.minor
            
            print("value \(x)   -  \(y)")
        }
        
        
        if ((knownBeacons.count > 1) && foundVenue){
            
            foundBeacon = [knownBeacons[0], knownBeacons[1]]  as [CLBeacon]
            
            sendToServer()
        }
        
        // check where you are at right class room
        if (!foundVenue){
            for beacon in knownBeacons{
                
                let bmajor = beacon.major.stringValue
                
                if (bmajor == venueMajor){
                    foundVenue = true
                    break
                }
            }
        }
        
        //after in right venue start broadcasting
        
        if (foundVenue && isSent) {

            
            print("Found venue")
            
            //broadcasting = true
            
            locationManager.stopRangingBeacons(in: region)
            
            broadcasting()
            
        }
        
          //          bluetoothPeripheralManager.stopAdvertising()
        if (foundVenue && isSent){
            
            if let lesson = lessons?[currentIndex.item]{
                lesson.st = 0
                
                self.collectionView!.reloadData()
            }
           /// let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: currentIndex) as! LessonCell
            
          
            
            isSent = false
            
            foundVenue = false
        }
        
    }
    
    func sendToServer(){
        
        let token = Constants.token
        
        let major1 = foundBeacon[0].major
        let minor1 = foundBeacon[0].minor
        let major2 = foundBeacon[1].major
        let minor2 = foundBeacon[1].minor
        
        // get ids of 2 classmate from beacon 
        
        var url = URL(string: Constants.baseURL + "/atk-ble/api/web/index.php/v1/beacon-user/get-user")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Accept": "application/json"
        ]
        let parameter: [String: Any] = [
            "major1" : major1,
            "minor1" : minor1,
            "major2" : major2,
            "minor2" : minor2
        ]
        
        var id1 = 0
        var id2 = 0
        Alamofire.request(url!, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            let responseJSON = response.result.value
            print(responseJSON)
            
            let data = JSON(responseJSON)
            id1 = data[0]["id"].int!
            id2 = data[1]["id"].int!
            
            print("response id \(id1)  \(id2)")

    }
    
        url = URL(string: Constants.baseURL + "/atk-ble/api/web/index.php/v1/beacon-attendance-student/student-list")
        
        let obj1 : [String : Any] = [
            "lesson_date_id": 24213,
            "student_id_1": "2",
            "student_id_2": 3,
            "status": 0
            ]
            
        let obj2 : [String : Any] = [
            "lesson_date_id": 24213,
            "student_id_1": "2",
            "student_id_2": 1,
            "status": 0
            ]

        self.isSent = true
//        var p = [[String: AnyObject]]()
//        p.append(obj1 as [String : AnyObject])
//        p.append(obj2 as [String : AnyObject])
//   
//        let parameters : [String:Any] = ["":p]
//        
//        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
//            let data = response.result.value
//            self.isSent = true
//        // let statusCode = response.response?.statusCode
//          //  print("dataresponse \(statusCode)")
//            print("data \(data)")
//            
//        }
    }


}
class LessonCell: BaseCell {
    
    //    let profileImageView: UIImageView = {
    //        let imageView = UIImageView()
    //        imageView.contentMode = .scaleAspectFill
    //        imageView.layer.cornerRadius = 34
    //        imageView.layer.masksToBounds = true
    //        return imageView
    //    }()
    
    var lesson: Lesson?{
        didSet {
            lecturerLabel.text = lesson?.lecturer
            lessonLabel.text = lesson?.lessonName
            venueLabel.text = lesson?.venue?.name
            let s = (lesson?.sTime!)! as String
            let t = (lesson?.eTime!)! as String
            timeLabel.text = s + "\n" + t
           // status = true
        //    print("status \(lesson?.st)")
            switch ((Int)((lesson?.st)!)){
                case -1 : statusImage.image = UIImage(named: "c")
                
                case 0  : statusImage.image = UIImage(named: "p")
                
            default: statusImage.image = UIImage(named: "pending")
                
            }
            
            
        }
    }
    
    let timeLabel: UILabel = {
        //        let view = UIView()
        //        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        //        return view
        
        let label = UILabel()
        label.text = "9:00 AM\n11:00 AM"
        label.numberOfLines = 2        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        
        return label
    }()
    
    let lecturerLabel: UILabel = {
        let label = UILabel()
        label.text = "ZZZ"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.00, green:0.36, blue:0.16, alpha:0.5)
       // view.backgroundColor = UIColor(red:0, green:0.92, blue:0.41, alpha:0.5)
        return view
    }()
    
    let lessonLabel: UILabel = {
        let label = UILabel()
        label.text = "Math"
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let venueLabel: UILabel = {
        let label = UILabel()
        label.text = "CS 121"
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        //  label.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.93, alpha:0.5)
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    let statusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupViews() {
        
        addSubview(timeLabel)
        addSubview(dividerLineView)
        
        setupContainerView()
        
     //   statusImage.image = UIImage(named: "dol")
        
        addConstraintsWithFormat("H:|-12-[v0(69)]", views: timeLabel)
        addConstraintsWithFormat("V:[v0(69)]", views: timeLabel)
        
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
    }
    
    fileprivate func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat("V:[v0(69)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(lecturerLabel)
        containerView.addSubview(lessonLabel)
        containerView.addSubview(venueLabel)
        containerView.addSubview(statusImage)
        
        containerView.addConstraintsWithFormat("V:|[v0(23)][v1(23)][v2(23)]|", views: lecturerLabel, lessonLabel, venueLabel)
        
        containerView.addConstraintsWithFormat("H:|[v0]-8-[v1(40)]-12-|", views: lessonLabel, statusImage)
        
        containerView.addConstraintsWithFormat("H:|[v0]-8-[v1(40)]-12-|", views: venueLabel, statusImage)
        
        containerView.addConstraintsWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: lecturerLabel, statusImage)
        
        containerView.addConstraintsWithFormat("V:[v0(20)]|", views: statusImage)
    }
    
  
}



