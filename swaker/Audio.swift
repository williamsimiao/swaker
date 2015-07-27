//
//  Audio.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class Audio: NSObject {
    var audio:NSData!
    var audioDescription:String?
    var senderId:String!
    
    init(audio:NSData!, audioDescription:String?, senderId:String!) {
        self.audio = audio
        self.audioDescription = audioDescription
        self.senderId = senderId
    }
}
