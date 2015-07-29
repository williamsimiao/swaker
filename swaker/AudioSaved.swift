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
    
    init(receiverId:String!, audio:NSData!, audioDescription:String?, senderId:String!) {
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.receiverId = receiverId
        
        var audioSufix = checkAudioSufix()
        self.audioId = "AUD_" + audioSufix
        audioSufix = ("\(audioSufix.toInt()!+1)")
        audioSufix.writeToFile(checkDirectory(""), atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        let receiverId = aDecoder.decodeObjectForKey("receiverId") as! String
        let audio = aDecoder.decodeObjectForKey("audio") as! NSData
        let audioDescription = aDecoder.decodeObjectForKey("audioDescription") as! String
        let senderId = aDecoder.decodeObjectForKey("senderId") as! String
        let audioId = aDecoder.decodeObjectForKey("audioId") as! String
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.receiverId = receiverId
        self.audioId = audioId
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(audio, forKey: "audio")
        aCoder.encodeObject(audioDescription, forKey: "audioDescription")
        aCoder.encodeObject(senderId, forKey: "senderId")
        aCoder.encodeObject(receiverId, forKey: "receiverId")
        aCoder.encodeObject(audioId, forKey: "audioId")

    }
    
    /*
        Salva o audio localmente da pasta Library
    */
    func SaveAudioInToLibrary() -> Bool {
        
        let success = NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(checkDirectory("SentAudios").stringByAppendingPathComponent(self.audioId + ".auf"), atomically: true)
        return success
    }
    
    /*
        Detela audio da pasta Library
    */
    func deleteAudioLocaly() -> Bool {
        
        var error:NSError?
        
        let pasta = checkDirectory("AudioLibrary")
        let path = pasta.stringByAppendingPathComponent("\(self.audioId).auf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        
        if !success {
            println(error?.localizedDescription)
        }
        return success
    }

}
