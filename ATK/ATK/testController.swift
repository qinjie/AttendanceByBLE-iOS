//
//  testController.swift
//  ATKdemo
//
//  Created by xuhelios on 12/16/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth
import Alamofire
import SwiftyJSON

class testController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(startBtn)
        view?.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   //     locationManager.startRangingBeacons(in: region)
        // Dispose of any resources that can be recreated.
    }
    
//    override func setupViews() {
//        addSubview(startBtn)
//    }
    
    let startBtn: UIButton = {
        //        let view = UIView()
        //        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        //        return view
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
       // btn.titleLabel?.text = "Start"
        btn.setTitle("Start", for: .normal)
        btn.backgroundColor = UIColor.orange
    //    btn.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControlEvents#>)
     //   btn.addTarget(self,action:#selector(startBtnAction),for:.touchUpInside)
        return btn
    }()
//    
//    
//    func startBtnAction(sender: UIButton)
//    {
//        var alertView = UIAlertView();
//        alertView.addButton(withTitle: "Ok");
//        alertView.title = "title";
//        alertView.message = "message";
//        alertView.show();
//    }
//    
//    var isScan = false
//        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "Estimotes")
//    var isSearchingForBeacons = false
//    
//    var locationManager: CLLocationManager!
//    
//    var lastFoundBeacon: CLBeacon! = CLBeacon()
//    
//    var lastProximity: CLProximity! = CLProximity.unknown
//    
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        
//                let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
//        
//                for beacon in knownBeacons{
//                    isScan = true
////                    let bmajor = beacon.major.stringValue
////                    //       let bminor = beacon.minor.stringValue
////                    majorscan.text = beacon.major.stringValue
////                    txtscan.text = beacon.proximityUUID.uuidString
////                    minorscan.text = beacon.minor.stringValue
////                    print(majorscan.text)
////                    if (bmajor == "123"){
////                        kt =  true
////                        break
////                    }
//        
//        
//                }
//        
//             //   combine scan & broading
//        //        if (kt == true) {
//        //            locationManager.stopRangingBeacons(in: region)
//        //            txtscan.text = "Already found & Stop Scan"
//        //            bluetoothPeripheralManager.stopAdvertising()
//        //        //    sendToServer()
//        //        }else{
//        //            if (isScan){
//        //                isBroadcasting = !isScan
//        //                broadcasting()
//        //            }
//        //
//        //        }
//        
//               //  just scan vanue and lesson
//                
//                if (isScan){
//                    locationManager.stopRangingBeacons(in: region)
//                    self.startBtn.setTitle("Found", for: .normal)
//                  //  bluetoothPeripheralManager.stopAdvertising()
//                }
//            }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
