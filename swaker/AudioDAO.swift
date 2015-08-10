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
    var audioTemporaryArray = [AudioAttempt]()
    
    //var audioAttemptArray: Array<AudioAttempt>?
    
    var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
    var receivedPath:String!
    var createdPath:String!
    //aqui salva os audios attempt ate eles tocarem
    var temporaryPath:String!
    
    static func sharedInstance() -> AudioDAO{
        if Instance == nil {
            Instance = AudioDAO()
            Instance?.receivedPath = Instance!.checkDirectory("Received")
            Instance?.createdPath = Instance!.checkDirectory("Created")
            Instance?.temporaryPath = Instance!.checkDirectory("Temporary")
            Instance?.loadAllAudios()
            
        }
        return Instance!
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
        let error = NSErrorPointer()
        let audioSufix = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: error)
        // atulizado para  mais 1 o sufixo
        var novoValor = ("\(audioSufix!.toInt()!+1)")
        novoValor.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: error)
        return audioSufix!
    }
    
    
    /*
    Carrega todos os audios que possuem o usuario do app como receiver no array AudioSavedArray
    CARREGA DO BANCO
    Medodo usado quando o usuario fizer login num novo device
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
    Checa se existe um driretorio 'directoryPath' na pasta documents, caso nao exista cria
    */
    
    func checkDirectory(directoryPath: String) -> String {
        var docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        let fullPath = docs.stringByAppendingPathComponent(directoryPath)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fullPath) {
            var error:NSError?
            NSFileManager.defaultManager().createDirectoryAtPath(fullPath, withIntermediateDirectories: false, attributes: nil, error: &error)
            println("criando \(directoryPath)")
            if error != nil {
                println(error?.localizedDescription)
            }
        }
        println("\(fullPath)")
        return fullPath
    }
    
    
    /*
    carrega os dois
    */
    func loadAllAudios() {
        loadReceivedAudios()
        loadCreatedAudios()
    }
    
    func loadReceivedAudios() {
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(receivedPath)
        while let fileName:String = enumerator?.nextObject() as? String {
            if fileName.hasSuffix("auf") {
                let filePath = receivedPath.stringByAppendingPathComponent(fileName)
                let data = NSData(contentsOfFile: filePath)
                
                /// MUDEI
                
                //var anAudio = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioSaved
                var anAudioAttempt = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioAttempt
                var anAudio = AudioSaved(myAudioAttempt: anAudioAttempt)
                
                
                audioReceivedArray.append(anAudio)
            }
        }
    }
    
    func loadCreatedAudios() {
        audioCreatedArray.removeAll(keepCapacity: true)
        let enumerator = NSFileManager.defaultManager().enumeratorAtPath(createdPath)
        while let fileName:String = enumerator?.nextObject() as? String {
            if fileName.hasSuffix("auf") {
                let filePath = createdPath.stringByAppendingPathComponent(fileName)
                let data = NSData(contentsOfFile: filePath)
                var anAudio = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioSaved
                audioCreatedArray.append(anAudio)
            }
        }
    }
    
    /*
    Carrega do BANCO todos os audios que possuem alarmId como o parametro alarmId
    Parametro: alarme
    */
    func loadAudiosFromAlarm(alarm:Alarm) {
        audioTemporaryArray.removeAll(keepCapacity: false)
        let AudioQuery = PFQuery(className: "AudioAttempt")
        let ArrayPFobjectsAttempt = AudioQuery.whereKey("alarmId", equalTo: alarm.objectId).findObjects()!
        for aPFobject in ArrayPFobjectsAttempt {
            var anAudio = AudioAttempt(alarmId: alarm.objectId as String, audio: (aPFobject["audio"] as! PFFile).getData()!, audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioTemporaryArray.append(anAudio)
        }
    }
    
    /*
    Movendo um audio do attempt para a o received
    */
    
    func moveToReceivedDir(audioId: String) {
        var docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        println("movendo")
        let origemPath = docs.stringByAppendingPathComponent("Temporary/\(audioId).auf")
        let destinationPath = docs.stringByAppendingPathComponent("Received/\(audioId).auf")
        let manager = NSFileManager.defaultManager()
        //copiando e edeletando em seguida
        var error:NSError?
        manager.copyItemAtPath(origemPath, toPath: destinationPath, error: &error)
        manager.removeItemAtPath(origemPath, error: &error)
        
    }
    
    /*
    Adiciona um novo audioAttempt ao banco
    Parametro: Classe AudioAttempt
    */
    func addAudioAttempt(anAudio:AudioAttempt) -> PFObject? {
        let PFAttempt = PFObject(className: "AudioAttempt")
        PFAttempt.setObject(anAudio.alarmId!, forKey: "alarmId")
        let file = PFFile(name: "nao_importa", data: anAudio.audio)
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
    
    func acceptAudioAttempt(audio:AudioAttempt) {
        //colocando audioId aceito com o alarme correspondente
        audio.saveAudioInToTemporaryDir()
        for(var i = 0 ;i < AlarmDAO.sharedInstance().userAlarms.count; i++){
            if AlarmDAO.sharedInstance().userAlarms[i].objectId == audio.alarmId {
                AlarmDAO.sharedInstance().userAlarms[i].audioId = audio.audioName //mudei a inicializacao com pfobject
                //isso vai dar treta
                break
            }
            println("\(AlarmDAO.sharedInstance().friendsAlarms.count)")
            
        }
        
        //just to be shure
        println("audioDescription:\(audio.audioDescription!)")
        
        for notif in UIApplication.sharedApplication().scheduledLocalNotifications {
            let notif = notif as! UILocalNotification
            //nem precisa checar a categoria aqui pq so mostra a action de accept pra essa categoria
            if notif.category == AppDelegate.categoriesIdentifiers.newAlarm.rawValue {
                UIApplication.sharedApplication().cancelLocalNotification(notif)
                let notifUserInfo = notif.userInfo as! [String:String!]
                
                ////////NAO FUNCIONA //////////MALDITO BUNDLE
                if notifUserInfo["alarmId"] == audio.alarmId {
                    notif.soundName = path.stringByAppendingPathComponent("Received").stringByAppendingPathComponent(audio.alarmId + ".caf")
                    UIApplication.sharedApplication().scheduleLocalNotification(notif)
                }
                ///////////////////////////////////
            }
        }
    }
}