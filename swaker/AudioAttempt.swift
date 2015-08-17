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
        self.audioName = self.alarmId
    }
    
    required init(coder aDecoder: NSCoder) {
        
        let alarmId = aDecoder.decodeObjectForKey("alarmId") as! String
        let audio = aDecoder.decodeObjectForKey("audio") as! NSData
        let audioDescription = aDecoder.decodeObjectForKey("audioDescription") as! String
        let senderId = aDecoder.decodeObjectForKey("senderId") as! String
        let audioName = aDecoder.decodeObjectForKey("audioName") as! String
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.alarmId = alarmId
        self.audioName = audioName
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(audio, forKey: "audio")
        aCoder.encodeObject(audioDescription, forKey: "audioDescription")
        aCoder.encodeObject(senderId, forKey: "senderId")
        aCoder.encodeObject(alarmId, forKey: "alarmId")
        aCoder.encodeObject(audioName, forKey: "audioName")
    }
    
    init(PFAudioAttempt:PFObject) {
        let audioPFFile = PFAudioAttempt["audio"] as! PFFile
        //there is fetching here
        let audioData = audioPFFile.getData()! as NSData
        super.init(audio: audioData, audioDescription: PFAudioAttempt["description"] as? String, senderId: PFAudioAttempt["senderId"] as! String)
        self.alarmId = PFAudioAttempt["alarmId"] as! String
        self.audioName = PFAudioAttempt.objectId
    }


    
    /*
        Salva o audio localmente da pasta Library
        Retorno: booleano de sucesso
    
        Obs: No banco o nome deste objecto e igual ao do arquivo
        EX: "Alarm.objectId".attempt
             hx2311jbfda423
    */
    func saveAudioInToTemporaryDir() -> Bool {
        // DESMUDEI
        let path = AudioDAO.sharedInstance().temporaryPath.stringByAppendingPathComponent(self.audioName)
        let success = NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(path + ".auf", atomically: true)
        self.audio.writeToFile(path + ".caf", atomically: true)
        return success
    }
    
    /*
        deletando audio da pasta Temporary
    */
    
    func deleteAudioLocaly() -> Bool {
        
        var error:NSError?
        
        let pasta = AudioDAO.sharedInstance().temporaryPath
        let path = pasta.stringByAppendingPathComponent(self.audioName)
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        
        if !success {
            println(error?.localizedDescription)
        }
        return success
    }
    
    
}
