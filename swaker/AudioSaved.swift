//
//  AudioSaved.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AudioSaved: Audio {
    
    var receiverId:String!
    
    init(receiverId:String!, audio:NSData!, audioDescription:String?, senderId:String!, audioId:String!) {
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId, audioId: audioId)
        self.receiverId = receiverId
    }
}
