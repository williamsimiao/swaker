//
//  AudioSaved.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class AudioSaved: Audio {
    
    var receiverId:String!
    
    init(receiverId:String!, audio:NSData!, audioDescription:String?, senderId:String!) {
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.receiverId = receiverId
        var audioSufix = checkAudioSufix()
//        self.audioName = "AUD_" + audioSufix
//        audioSufix = ("\(audioSufix.toInt()!+1)")
//        audioSufix.writeToFile(checkDirectory(""), atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        self.audioName = self.senderId + "_" + self.receiverId + ".auf"
        
    }

    required init(coder aDecoder: NSCoder) {
        let receiverId = aDecoder.decodeObjectForKey("receiverId") as! String
        let audio = aDecoder.decodeObjectForKey("audio") as! NSData
        let audioDescription = aDecoder.decodeObjectForKey("audioDescription") as! String
        let senderId = aDecoder.decodeObjectForKey("senderId") as! String
        let audioName = aDecoder.decodeObjectForKey("audioName") as! String
        super.init(audio: audio, audioDescription: audioDescription, senderId: senderId)
        self.receiverId = receiverId
        self.audioName = audioName
    }
    
    init(PFAudioSaved:PFObject) {
        let audioPFFile = PFAudioSaved["audio"] as! PFFile
        //there is fetching here
        let audioData = audioPFFile.getData()! as NSData 
        super.init(audio: audioData, audioDescription: PFAudioSaved["description"] as? String, senderId: PFAudioSaved["senderId"] as! String)
        self.receiverId = PFUser.currentUser()?.objectId
        self.audioName = audioPFFile.name
    }
    
    init(myAudioAttempt: AudioAttempt) {
        super.init(audio: myAudioAttempt.audio, audioDescription: myAudioAttempt.audioDescription, senderId: myAudioAttempt.senderId)
        self.receiverId = UserDAO.sharedInstance().currentUser?.objectId
        self.audioName = myAudioAttempt.audioName
    }

    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(audio, forKey: "audio")
        aCoder.encodeObject(audioDescription, forKey: "audioDescription")
        aCoder.encodeObject(senderId, forKey: "senderId")
        aCoder.encodeObject(receiverId, forKey: "receiverId")
        aCoder.encodeObject(audioName, forKey: "audioName")
    }
    
    /*
    
        Gera um sufixo a partir do numero lido no arquivo 'AudioSufixCounter'
        Esse sufixo sera o nome do arquivo de audio
    */
    func checkAudioSufix() -> String {
        let path = AudioDAO.sharedInstance().checkDirectory("").stringByAppendingPathComponent("AudioSufixCounter")
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(path)) {
            let audioSufixCounter = "1"
            audioSufixCounter.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        let audioSufix = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
        return audioSufix!
    }
    
    /*
        Convertedo para PFObject
    */
    func toPFObject() -> PFObject {
        var object = PFObject()
        let audioPFFile = PFFile(name: audioName, data: audio)
//        object = PFObject(className: "AudioSaved", dictionary: ["audio":audioPFFile, "description":audioDescription, "receiverId":receiverId, "senderId":senderId!])
        object = PFObject(className: "AudioSaved")
        object["audio"] = audioPFFile
        object["description"] = audioDescription
        object["receiverId"] = receiverId
        object["senderId"] = senderId
        return object
    }

    
    /*
        Salva um audio saved no diretorio passado
        Retorno: booleano de sucesso
        OBS: esse metodo deveria ficar na AudioDAO
    */
    func SaveAudioInToDirectoy(directory: String) -> Bool {
        //tirei a extensao auf
        let manager = NSFileManager.defaultManager()
        //aqui ja faz a checagem se o path existe, se nao existir cria
        var path = AudioDAO.sharedInstance().checkDirectory(directory) as String
//        var error:NSError?
//        if !manager.fileExistsAtPath(path) {
//            manager.createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil, error: &error)        }
        path.stringByAppendingPathComponent(self.audioName)
        println("SALVANDO tipo SAVED: \(self.audioName)")
        let success = NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(path, atomically: true)
        return success
    }
    
    /*
        Detela audio da pasta Library
        Retorno: booleano de sucesso
    */
    func deleteAudioLocaly() -> Bool {
        
        var error:NSError?
        
        let pasta = AudioDAO.sharedInstance().checkDirectory("Saved")
        let path = pasta.stringByAppendingPathComponent("\(self.audioName).auf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        
        if !success {
            println(error?.localizedDescription)
        }
        return success
    }
}