//
//  ATKController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit
import CoreLocation


class ATKController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var catalog: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var starttime: UILabel!
    @IBOutlet weak var endtime: UILabel!
    @IBOutlet weak var id1: UILabel!
    @IBOutlet weak var id2: UILabel!
    
    var currentLesson : Lesson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.requestAlwaysAuthorization()
//        let uuid = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D") as! UUID
//        let newRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "xuhelios" )
//        
//        locationManager.startMonitoring(for: newRegion)
        
    }
 

}
