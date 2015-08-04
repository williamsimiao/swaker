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
    
    var audioCreatedArray = [AudioSaved]()
    var audioReceivedArray = [AudioSaved]()
    var audioAttemptArray = [AudioAttempt]()
    //var audioAttemptArray: Array<AudioAttempt>?
    
    var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
    
    static func sharedInstance() -> AudioDAO{
        if Instance == nil {
            Instance = AudioDAO()
            Instance?.loadCreatedAudios()
            Instance?.loadReceivedAudios()

        }
        return Instance!
    }
        
    /*
        Carrega todos os audios que possuem o usuario do app como receiver no array AudioSavedArray
        CARREGA DO BANCO
    */
    func loadSavedAudios() {
        
        let AudioQuery = PFQuery(className: "AudioSaved")
        let ArrayPFobjectsReceived = AudioQuery.whereKey("receiverId", equalTo: PFUser.currentUser()!.objectId!).findObjects()!
        
        for aPFobject in ArrayPFobjectsReceived {
            var anAudio = AudioSaved(receiverId: aPFobject["receiverId"] as! String, audio: aPFobject["audio"] as! NSData, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioReceivedArray.append(anAudio)
        }
        
        let ArrayPFobjectsCreated = AudioQuery.whereKey("senderId", equalTo: PFUser.currentUser()!.objectId!).findObjects()!
        
        for aPFobject in ArrayPFobjectsCreated {
            var anAudio = AudioSaved(receiverId: aPFobject["receiverId"] as! String, audio: aPFobject["audio"] as! NSData, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioReceivedArray.append(anAudio)
        }
    }
    
    /*
        CARREGA DA PASTA "Received"
    */
    func loadReceivedAudios() {
        //path to de directory "received"
        let receivedPath = path.stringByAppendingPathComponent("Received")
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(receivedPath)
        while let fileName:String = enumerator?.nextObject() as? String{
            if fileName.hasSuffix("auf") {
                let filePath = receivedPath.stringByAppendingPathComponent(fileName)
                let data = NSData(contentsOfFile: filePath)
                var anAudio = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioSaved
                audioReceivedArray.append(anAudio)
            }
        }
    }
    
    /*
        CARREGA DA PASTA "Created"
    */
    func loadCreatedAudios() {
        //path to de directory "created"
        let createdPath = path.stringByAppendingPathComponent("Received")
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(createdPath)
        while let fileName:String = enumerator?.nextObject() as? String{
            if fileName.hasSuffix("auf") {
                let filePath = createdPath.stringByAppendingPathComponent(fileName)
                let data = NSData(contentsOfFile: filePath)
                var anAudio = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioSaved
                audioCreatedArray.append(anAudio)
            }
        }
    }

    
    /*
        Carrega todos os audios que possuem alarmId como o parametro alarmId
        Parametro: ID do alarme
    */
    func loadAudiosFromAlarm(alarmId: String) {
        audioAttemptArray.removeAll(keepCapacity: false)
        let AudioQuery = PFQuery(className: "AudioAttempt")
        let ArrayPFobjectsAttempt = AudioQuery.whereKey("alarmId", equalTo: alarmId).findObjects()!
        for aPFobject in ArrayPFobjectsAttempt {
            var anAudio = AudioAttempt(alarmId: alarmId as String, audio: (aPFobject["audio"] as! PFFile).getData()!, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioAttemptArray.append(anAudio)
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
        else {
            //Mostra um erro pro usuario
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
    
    /*
        deleta audio da classe audooAttempt do banco
        Parametro: PFObject
    */
    func deleteAudioAttempt(audioObject: PFObject) -> Bool {
        
        let success = PFObject(withoutDataWithClassName: "AudioAttempt", objectId: audioObject.objectId).delete()
        return success
    }
    
    /*
        metodo para deletar audio da classe audioSaved do banco
    */
    
    func deleteAudioSaved(audioSaved: AudioSaved) {
        let audioObject = audioSaved.toPFObject()
        PFObject(withoutDataWithClassName: "AudioSaved", objectId: audioObject.objectId).deleteEventually()
    }
    
    func convertPFObjectTOAudioSaved (audioObject: PFObject) -> AudioSaved{
        
        let receivedAudio = AudioSaved(receiverId: audioObject["receiverId"] as! String, audio: audioObject["audio"] as! NSData, audioDescription: audioObject["description"] as? String, senderId: audioObject["senderId"] as! String)
        
        return receivedAudio
    }
    
    
    
}
