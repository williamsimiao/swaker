//
//  AudioAttempt.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class AudioAttempt: Audio {
    var alarmId:String!
    
    init(alarmId:String!, audio:NSData!, audioDescription:String!, senderId:String!) {
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.alarmId = alarmId
        
        var audioSufix = checkAudioSufix()
        self.audioId = "AUD_" + audioSufix
        audioSufix = ("\(audioSufix.toInt()!+1)")
        println("sufix:\(audioSufix)")
        let path = checkDirectory("").stringByAppendingPathComponent("AudioSufixCounter")
        audioSufix.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func convertToSaved() -> AudioSaved {
        let saved = AudioSaved(receiverId: alarmId, audio: self.audio, audioDescription: self.audioDescription, senderId: self.senderId)
        
        return saved
    }
}
