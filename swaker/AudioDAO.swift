//
//  AudioDAO.swift
//  swaker
//
//  Created by William on 7/27/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse


class AudioDAO: NSObject {

    static var Instance: AudioDAO?
    
    var AudioSavedArray: Array<AudioSaved>?
    var AudioAttemptArray: Array<AudioAttempt>?
    var audioPath: String!
    
    static func sharedInstance() -> AudioDAO{
        if Instance == nil {
            Instance = AudioDAO()
        }
        return Instance!
    }
    
    /*
        Carrega todos os audios que possuem o usuario do app como receiver no array AudioSavedArray
    */
    func checkDirectory(directoryPath: String) -> String {
        let docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        let fullPath = docs.stringByAppendingPathComponent(directoryPath)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fullPath) {
            var error:NSError?
            NSFileManager.defaultManager().createDirectoryAtPath(fullPath, withIntermediateDirectories: false, attributes: nil, error: &error)
            println("criando \(directoryPath)")
            if error != nil {
                println(error?.localizedDescription)
            }
        }
        return fullPath
    }
    
    func loadSavedAudios() {
        
        let AudioQuery = PFQuery(className: "AudioSaved")
        let ArrayPFobjectsSaved = AudioQuery.whereKey("receiverId", equalTo: PFUser.currentUser()!.objectId!).findObjects()!
        
        for anPFobject in ArrayPFobjectsSaved {
            var anAudio = AudioSaved(receiverId: anPFobject["receiverId"] as! String, audio: anPFobject["audio"] as! NSData, audioDescription: anPFobject["description"] as? String, senderId: anPFobject["senderId"] as! String, audioId: anPFobject["objectId"] as! String)
            AudioSavedArray?.append(anAudio)
        }
    }
    
    /*
        Carrega todos os audios que possuem alarmId como o parametro alarmId
        Parametro: ID do alarme
    */
    func loadAudiosFromAlarm(alarmId: String) {
        
        let AudioQuery = PFQuery(className: "AudioAttempt")
        let ArrayPFobjectsAttempt = AudioQuery.whereKey("AlarmId", equalTo: alarmId).findObjects()!
        for aPFobject in ArrayPFobjectsAttempt {
            var anAudio = AudioAttempt(alarmId: alarmId as String, audio: aPFobject["audio"] as! NSData, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String, audioId: aPFobject["objectId"] as! String)
            AudioAttemptArray?.append(anAudio)
        }
    }
    
    /*
        Adiciona um novo audioAttempt ao banco
        Parametro: Classe AudioAttempt
    */
    func addAudioAttempt(anAudio:AudioAttempt)  {
        let PFAttempt = PFObject(className: "AudioAttempt")
        PFAttempt.setObject(anAudio.alarmId!, forKey: "alarmId")
        PFAttempt.setObject(anAudio.audio, forKey: "audio")
        PFAttempt.setObject(anAudio.audioDescription!, forKey: "description")
        PFAttempt.setObject(anAudio.senderId, forKey: "senderId")
        
        //deveria ser saveInBackGround
        if(!PFAttempt.save()){
            // Avisa o usuario
        }
        //sava na biblioteca memsmo que a gravacao no banco nao ocorra
        NSKeyedArchiver.archivedDataWithRootObject(AudioAttempt).writeToFile(checkDirectory("SentAudios").stringByAppendingPathComponent(anAudio.audioId), atomically: true)
    }
    
    
    
}
