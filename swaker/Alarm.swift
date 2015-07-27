//
//  Alarm.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class Alarm: NSObject, NSCoding {
    var audioId:String!
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
        audioId = aDecoder.decodeObjectForKey("audioId") as! String
        alarmDescription = aDecoder.decodeObjectForKey("alarmDescription") as! String
        fireDate = aDecoder.decodeObjectForKey("fireDate") as! NSDate
        setterId = aDecoder.decodeObjectForKey("setterId") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(audioId, forKey: "audioId")
        aCoder.encodeObject(alarmDescription, forKey: "alarmDescription")
        aCoder.encodeObject(fireDate, forKey: "fireDate")
        aCoder.encodeObject(setterId, forKey: "setterId")
    }
}
