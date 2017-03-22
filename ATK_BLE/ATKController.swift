//
//  ATKController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit
import CoreLocation


class ATKController: UITableViewController , CLLocationManagerDelegate  {

    @IBOutlet weak var catalog: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var starttime: UILabel!
    @IBOutlet weak var endtime: UILabel!
    @IBOutlet weak var id1: UILabel!
    @IBOutlet weak var id2: UILabel!
    
    var lesson : Lesson!
    var uuids : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starttime.text = lesson.start_time
        endtime.text = lesson.end_time
        catalog.text = lesson.catalog
        uuid.text = uuids
        
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.requestAlwaysAuthorization()
//        let uuid = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D") as! UUID
//        let newRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "xuhelios" )
//        
//        locationManager.startMonitoring(for: newRegion)
        
    }
 

}
