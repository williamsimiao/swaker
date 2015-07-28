//
//  Alarm.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class Alarm: NSObject, NSCoding {
    var objectId:String!
    var audioId:String! {
        didSet {
            self.toPFObject().save()
        }
    }
    var alarmDescription:String!
    var fireDate:NSDate!
    var setterId:String!
    
    init(audioId:String!, alarmDescription:String!, fireDate:NSDate, setterId:String!) {
        self.audioId = audioId
        self.alarmDescription = alarmDescription
        self.fireDate = fireDate
        self.setterId = setterId
    }
    
    required init(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObjectForKey("objectId") as? String
        audioId = aDecoder.decodeObjectForKey("audioId") as! String
        alarmDescription = aDecoder.decodeObjectForKey("alarmDescription") as! String
        fireDate = aDecoder.decodeObjectForKey("fireDate") as! NSDate
        setterId = aDecoder.decodeObjectForKey("setterId") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectId, forKey: "objectId")
        aCoder.encodeObject(audioId, forKey: "audioId")
        aCoder.encodeObject(alarmDescription, forKey: "alarmDescription")
        aCoder.encodeObject(fireDate, forKey: "fireDate")
        aCoder.encodeObject(setterId, forKey: "setterId")
    }
    
    init(PFAlarm:PFObject) {
        self.objectId = PFAlarm.objectId
        self.audioId = PFAlarm["audioId"] as! String
        self.alarmDescription = PFAlarm["description"] as! String
        self.fireDate = PFAlarm["fireDate"] as! NSDate
        self.setterId = PFAlarm["setterId"] as! String
    }
    
    func toPFObject() -> PFObject {
        let object = PFObject(className: "Alarm", dictionary: ["audioId":audioId, "description":alarmDescription, "fireDate":fireDate, "setterId":setterId])
        object.objectId = objectId
        return object
    }
}
