//
//  AudioAttempt.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AudioAttempt: Audio {
    var alarmId:String?
    
    init(alarmId:String!, audio:NSData!, audioDescription:String?, senderId:String!) {
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.alarmId = alarmId
    }
}
