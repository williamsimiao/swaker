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
        self.audioName = "AUD_" + audioSufix
        audioSufix = ("\(audioSufix.toInt()!+1)")
        audioSufix.writeToFile(checkDirectory(""), atomically: true, encoding: NSUTF8StringEncoding, error: nil)
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
        let path = checkDirectory("").stringByAppendingPathComponent("AudioSufixCounter")
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(path)) {
            let audioSufixCounter = "1"
            audioSufixCounter.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        let audioSufix = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
        return audioSufix!
    }

    
    /*
        Salva o audio localmente da pasta Library
        Retorno: booleano de sucesso
        Obs: No banco o nome deste objecto e diferente ao do arquivo
        pasta: AUD_01.auf
        Banco: AUD_01
    
    */
    func SaveAudioInToLibrary() -> Bool {
        
        let success = NSKeyedArchiver.archivedDataWithRootObject(self).writeToFile(checkDirectory("Saved").stringByAppendingPathComponent(self.audioName + ".auf"), atomically: true)
        return success
    }
    
    /*
        Detela audio da pasta Library
        Retorno: booleano de sucesso
    */
    func deleteAudioLocaly() -> Bool {
        
        var error:NSError?
        
        let pasta = checkDirectory("Saved")
        let path = pasta.stringByAppendingPathComponent("\(self.audioName).auf")
        let success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        
        if !success {
            println(error?.localizedDescription)
        }
        return success
    }
}