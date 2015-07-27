//
//  Alarm.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class Alarm: NSObject {
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
}
