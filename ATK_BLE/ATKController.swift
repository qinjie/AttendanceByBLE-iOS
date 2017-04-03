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
    @IBOutlet weak var starttime: UILabel!
    @IBOutlet weak var endtime: UILabel!
    
    @IBOutlet weak var acad: UILabel!
    @IBOutlet weak var lecturername: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var classSection: UILabel!
    
    var lesson : Lesson!
    var uuids : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starttime.text = lesson.start_time
        endtime.text = lesson.end_time
        catalog.text = lesson.catalog! + " " + lesson.subject! + " " + (lesson.lesson_id?.description)!
        room.text = lesson.location
        venue.text = lesson.venueName
        lecturername.text = lesson.lecturer
        acad.text = lesson.acad
        email.text = lesson.email
        

        
    }
 
  
   }
