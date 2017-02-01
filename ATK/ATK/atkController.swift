//
//  ViewController.swift
//  BeaconPop
//
//  Created by xuhelios on 11/30/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//
//beacon May Quet va phat song beacon

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth
import Alamofire
import SwiftyJSON


class atkController: UIViewController, CLLocationManagerDelegate  {
//     CBPeripheralManagerDelegate,
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var back: UIButton!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.unknown
//
    @IBOutlet weak var majorscan: UITextField!
    @IBOutlet weak var minorscan: UITextField!
    @IBOutlet weak var txtscan: UITextField!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblBTStatus: UILabel!
//
//    //    @IBOutlet weak var txtMajor: UITextField!
//    //
//    //    @IBOutlet weak var txtMinor: UITextField!
//    
//    
//    //let uuid = NSUUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
//    let uuid = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
//    let txtMajor = "123"
//    let txtMinor = "456"
//    
//    var beaconRegion: CLBeaconRegion!
//    
     var kt = false
//    
//    var bluetoothPeripheralManager: CBPeripheralManager!
//    
//    var isBroadcasting = false
//    
//    
//    var dataDictionary = NSDictionary()
//    
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
        
   //     btnAction.layer.cornerRadius = 20 //btnAction.frame.size.width / 2
        
//        var swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeGestureRecognizer:")
//        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
//        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        
      //  bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
    }
    
    
//    
//    var k = true
    var isScan = false
//    
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        
//        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
//        
//        for beacon in knownBeacons{
//            isScan = true
//            let bmajor = beacon.major.stringValue
//            //       let bminor = beacon.minor.stringValue
//            majorscan.text = beacon.major.stringValue
//            txtscan.text = beacon.proximityUUID.uuidString
//            minorscan.text = beacon.minor.stringValue
//            print(majorscan.text)
//            if (bmajor == "123"){
//                kt =  true
//                break
//            }
//            
//    
//        }
//    
//     //   combine scan & broading
////        if (kt == true) {
////            locationManager.stopRangingBeacons(in: region)
////            txtscan.text = "Already found & Stop Scan"
////            bluetoothPeripheralManager.stopAdvertising()
////        //    sendToServer()
////        }else{
////            if (isScan){
////                isBroadcasting = !isScan
////                broadcasting()
////            }
////            
////        }
//        
//       //  just scan vanue and lesson
//        
//        if (isScan){
//            locationManager.stopRangingBeacons(in: region)
//            txtscan.text = "Already found & Stop Scan"
//          //  bluetoothPeripheralManager.stopAdvertising()
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //
    //
    //    // MARK: Custom method implementation
    //
    //    func handleSwipeGestureRecognizer(_ gestureRecognizer: UISwipeGestureRecognizer) {
    //        txtMajor.resignFirstResponder()
    //        txtMinor.resignFirstResponder()
    //    }
    
    
    // MARK: IBAction method implementation
    
//    
//    @IBAction func switchBroadcastingState(_ sender: Any) {
//
//        locationManager = CLLocationManager()
//        //   let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
//        locationManager.delegate = self
//        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
//            locationManager.requestWhenInUseAuthorization()
//        }
//        locationManager.startRangingBeacons(in: region)
//        
//        
//    }
//    func sendToServer(){
//        let baseUrl = "http://188.166.247.154/"
//        let token = "Bearer QAMoEorbGpaE6j1__4MyCQRedeHDskzJ"
//        var ma = majorscan.text
//        var mi = minorscan.text
//        
//        //  let urlString = baseUrl + "api/web/index.php/v1/test/create"
//        let url = URL(string: baseUrl + "atk-ble/api/web/index.php/v1/test/create")
//        let headers: HTTPHeaders = [
//            "Authorization": token,
//            "Accept": "application/json"
//        ]
//        let parameters: [String: Any] = [
//            "major1" : ma,
//            "minor1" : mi,
//            "major2" : "0",
//            "minor2" : "0"
//        ]
//        
//        
//        
//        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
//            let data = response.result.value
//            //                guard let responseJSON = response.result.value as? [String: AnyObject] else {
//            //                    print("Parse error")
//            //                    return
//            //                }
//            //
//            //                let json = JSON(responseJSON)
//            //                print(json)
//            print(data)
//            
//        }
//        btnAction.setTitle("Done", for: UIControlState.normal)
//        lblStatus.text = "Sent to server"
//    }
    
//    
//    func broadcasting(){
//        
//        if !isBroadcasting {
//            // if (txtscan.text == "ok"){
//            // if (kt == true){
//            
//            if bluetoothPeripheralManager.state == .poweredOn {
//                //                let major = UInt16(txtMajor.text!)! as CLBeaconMajorValue
//                //                let minor = UInt16(txtMinor.text!)! as CLBeaconMajorValue
//                
//                let major = UInt16(txtMajor)! as CLBeaconMajorValue
//                let minor = UInt16(txtMinor)! as CLBeaconMajorValue
//                
//                
//                beaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, major: major, minor: minor, identifier: "com.xuhelios.beaconpop")
//                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
//                bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : Any])
//                btnAction.setTitle("Stop", for: UIControlState.normal)
//                lblStatus.text = "Broadcasting..."
//                //
//                //                txtMajor.isEnabled = false
//                //                txtMinor.isEnabled = false
//                isBroadcasting = true
//            }
//            else{
//                bluetoothPeripheralManager.stopAdvertising()
//                
//                btnAction.setTitle("Start", for: UIControlState.normal)
//                lblStatus.text = "Stopped"
//                
//                //                txtMajor.isEnabled = true
//                //                txtMinor.isEnabled = true
//                
//                
//                isBroadcasting = false
//            }
//            
//        }
        //        else{
        //            bluetoothPeripheralManager.stopAdvertising()
        //
        //            btnAction.setTitle("Start", for: UIControlState.normal)
        //            lblStatus.text = "Stopped"
        //
        //            //            txtMajor.isEnabled = true
        //            //            txtMinor.isEnabled = true
        //
        //
        //            isBroadcasting = false
        //            //      }
        //
        //        }
        
   // }
    
    
    
//    
//    // MARK: CBPeripheralManagerDelegate method implementation
    //
//    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        var statusMessage = ""
//        
//        switch peripheral.state {
//        case .poweredOn:
//            statusMessage = "Bluetooth Status: \n Turned On"
//            
//        case .poweredOff:
////            if isBroadcasting {
////          //      switchBroadcastingState(self)
////            }
//            statusMessage = "Bluetooth Status: \n Turned Off"
//            
//        case .resetting:
//            statusMessage = "Bluetooth Status: \n Resetting"
//            
//        case .unauthorized:
//            statusMessage = "Bluetooth Status: \n Not Authorized"
//            
//        case .unsupported:
//            statusMessage = "Bluetooth Status: \n Not Supported"
//            
//        default:
//            statusMessage = "Bluetooth Status: \n Unknown"
//        }
//        
//        lblBTStatus.text = statusMessage
//    }

}

