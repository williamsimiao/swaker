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
    
    var audioSavedArray: Array<AudioSaved>?
    var audioAttemptArray: Array<AudioAttempt>?
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
    func loadSavedAudios() {
        audioSavedArray = [AudioSaved]()
        
        let AudioQuery = PFQuery(className: "AudioSaved")
        let ArrayPFobjectsSaved = AudioQuery.whereKey("receiverId", equalTo: PFUser.currentUser()!.objectId!).findObjects()!
        
        for aPFobject in ArrayPFobjectsSaved {
            var anAudio = AudioSaved(receiverId: aPFobject["receiverId"] as! String, audio: aPFobject["audio"] as! NSData, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioSavedArray?.append(anAudio)
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
            var anAudio = AudioAttempt(alarmId: alarmId as String, audio: aPFobject["audio"] as! NSData, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioAttemptArray?.append(anAudio)
        }
    }
    
    /*
        Adiciona um novo audioAttempt ao banco
        Parametro: Classe AudioAttempt
    */
    func addAudioAttempt(anAudio:AudioAttempt) -> PFObject? {
        let PFAttempt = PFObject(className: "AudioAttempt")
        PFAttempt.setObject(anAudio.alarmId!, forKey: "alarmId")
        
        let file = PFFile(name: anAudio.audioName, data: anAudio.audio)
        
        PFAttempt.setObject(file, forKey: "audio")
        PFAttempt.setObject(anAudio.audioDescription!, forKey: "description")
        PFAttempt.setObject(anAudio.senderId, forKey: "senderId")
        if PFAttempt.save() {
            return PFAttempt
        }
        return nil
        //adicione um bloco para alterar o nome do audio para o PFobject.objectId

    }
    
    func addAudioSaved(anAudio:AudioSaved) -> PFObject {
        let PFAttempt = PFObject(className: "AudioSaved")
        PFAttempt.setObject(anAudio.receiverId!, forKey: "alarmId")
        
        let file = PFFile(name: anAudio.audioName, data: anAudio.audio)
        
        PFAttempt.setObject(file, forKey: "audio")
        PFAttempt.setObject(anAudio.audioDescription!, forKey: "description")
        PFAttempt.setObject(anAudio.senderId, forKey: "senderId")
        PFAttempt.save()
        
        //adicione um bloco para alterar o nome do audio para o PFobject.objectId
        return PFAttempt
    }
    
    func deleteAudioAttempt(audioObject: PFObject) {
        
        PFObject(withoutDataWithClassName: "AudioAttempt", objectId: audioObject.objectId).deleteEventually()
    
    }
    
    func deleteAudioSaved(audioObject: PFObject) {
        
        var error:NSError?

        PFObject(withoutDataWithClassName: "AudioSaved", objectId: audioObject.objectId).deleteEventually()
        
    }
    
}
