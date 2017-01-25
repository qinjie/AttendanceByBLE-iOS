//
//  Item.swift
//  WeTrack1
//
//  Created by xuhelios on 1/9/17.
//  Copyright © 2017 sg. All rights reserved.
//
//  Converted with Swiftify v1.0.6214 - https://objectivec2swift.com/
//
//  RWTItem.h
//  ForgetMeNot
//
//  Created by Chris Wagner on 1/29/14.
//  Copyright (c) 2014 Ray Wenderlich Tutorial Team. All rights reserved.
//
import Foundation
import CoreLocation
class Item {
    private(set) var name = ""
    private(set) var uuid: UUID!
    private(set) var majorValue = CLBeaconMajorValue()
    private(set) var minorValue = CLBeaconMinorValue()
    var lastSeenBeacon: CLBeacon!
    
    init(name: String, uuid: UUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) {
        //        super.init()
        self.name = name
        self.uuid = uuid
        self.majorValue = major
        self.minorValue = minor
    }
    
    func isEqual(to beacon: CLBeacon) -> Bool {
        if (beacon.proximityUUID.uuidString == self.uuid.uuidString) && beacon.major.isEqual((self.majorValue)) && beacon.minor.isEqual((self.minorValue)) {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - NSCoding
    
    //    required init?(coder aDecoder: NSCoder) {
    //        super.init()
    //        self.name = aDecoder.decodeObject(forKey: kRWTItemNameKey)! as! String
    //        self.uuid = aDecoder.decodeObject(forKey: kRWTItemUUIDKey)! as! UUID
    //        self.majorValue = CUnsignedInt(aDecoder.decodeObject(forKey: kRWTItemMajorValueKey)!)
    //        self.minorValue = CUnsignedInt(aDecoder.decodeObject(forKey: kRWTItemMinorValueKey)!)
    //    }
    //
    //    override func encode(withCoder aCoder: NSCoder) {
    //        aCoder.encodeObject(self.name, forKey: kRWTItemNameKey)
    //        aCoder.encodeObject(self.uuid, forKey: kRWTItemUUIDKey)
    //        aCoder.encodeObject(Int(self.majorValue), forKey: kRWTItemMajorValueKey)
    //        aCoder.encodeObject(Int(self.minorValue), forKey: kRWTItemMinorValueKey)
    //    }
}
//
//  RWTItem.m
//  ForgetMeNot
//
//  Created by Chris Wagner on 1/29/14.
//  Copyright (c) 2014 Ray Wenderlich Tutorial Team. All rights reserved.
//
let kRWTItemNameKey = "name"

let kRWTItemUUIDKey = "uuid"

let kRWTItemMajorValueKey = "major"

let kRWTItemMinorValueKey = "minor"
