//
//  ViewController.swift
//  WeTrack1
//
//  Created by xuhelios on 1/9/17.
//  Copyright © 2017 sg. All rights reserved.
//


import CoreLocation

import UIKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    

    let uuid = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D") as! UUID
    let major = 24890 as CLBeaconMajorValue
    let minor = 6699 as CLBeaconMinorValue
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        var beaconRegion = CLBeaconRegion(proximityUUID: self.uuid, major: self.major, minor: self.minor, identifier: "Hello")
        self.locationManager.startMonitoring(for: beaconRegion)
        self.pro.text = "Runing...."
        //self.loadItems()
    }
    

    @IBOutlet weak var pro: UILabel!
    @IBOutlet weak var uuidTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var majorIdTextField: UITextField!
    @IBOutlet weak var minorIdTextField: UITextField!

//    
//    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//        print("Failed monitoring region: \(error)")
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error?) {
//        print("Location manager failed: \(error)")
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        
//        //self.detailTextLabel!.text = "Location: \(self.name(for: self.item.lastSeenBeacon.proximity))"
//
//    }

    
}


