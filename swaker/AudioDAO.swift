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
    
    
    /**
        Carrega todos os audios que possuem o usuario do app como receiver no array AudioSavedArray
        CARREGA DO BANCO
        Medodo usado quando o usuario fizer login num novo device
    **/
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
                
                /// DESMUDEI
                
                var anAudio = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioSaved
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
        let audioQuery = PFQuery(className: "AudioAttempt").whereKey("alarmId", equalTo: alarm.objectId)
        let arrayPFobjectsAttempt = audioQuery.findObjects()!
        for aPFobject in arrayPFobjectsAttempt {
            var anAudio = AudioAttempt(alarmId: alarm.objectId as String, audio: NSData(), audioDescription: aPFobject["description"] as? String, senderId: aPFobject["senderId"] as! String)
            audioTemporaryArray.append(anAudio)
        }
        println("aehooo")
    }
    
    /*
        Movendo um audio do attempt para a o received
        1- crio um audioSaved a partir do attempt
        2- salvo esse novo audio na pasta received assim como o caf 
            (isso e feito em saveAudioInToReceivedDir)
        3- deleto o audio attempt da pasta temporary
    */
    
    func moveToReceivedDir(audioName: String) {
        var docs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        var origemPath = docs.stringByAppendingPathComponent("Temporary/\(audioName).auf")
        let destinationPath = docs.stringByAppendingPathComponent("Received/\(audioName).auf")
        let manager = NSFileManager.defaultManager()
        var error:NSError?
        let data = NSData(contentsOfFile: origemPath)
        var anAttempt = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! AudioAttempt
        let SavedFromAttempt = AudioSaved(myAudioAttempt: anAttempt)
        SavedFromAttempt.saveAudioInToReceivedDir()
        manager.removeItemAtPath(origemPath, error: &error)
        //agora vamos deletar o caf, tb vamos reutizar origemPath
        origemPath = docs.stringByAppendingPathComponent("Temporary/\(audioName).caf")
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
            println("mudando:\(anAudio.audioName)")
            anAudio.audioName = PFAttempt.objectId
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
    
    func deleteAudioSaved(audioToDelete: AudioSaved, isOfKindCreated: Bool) -> Bool {
        var error: NSError?
        var path = String()
        let success: Bool
        if isOfKindCreated == true {
            path = AudioDAO.sharedInstance().createdPath
            println("\(path)")
            path = path.stringByAppendingPathComponent(audioToDelete.audioName + ".auf")
            if NSFileManager.defaultManager().fileExistsAtPath(path){
                println("exist so delete: \(path) END")
            }
            success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        }
        else {
            path = AudioDAO.sharedInstance().receivedPath
            path = path.stringByAppendingPathComponent(audioToDelete.audioName + ".auf")
            if NSFileManager.defaultManager().fileExistsAtPath(path){
                println("exist so delete: \(path) END")
            }
            success = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
        }
        
        if !success {
            println(error?.localizedDescription)
            return false
        }
        return true
    }
    
    func convertPFObjectTOAudioSaved (audioObject: PFObject) -> AudioSaved{
        
        let receivedAudio = AudioSaved(receiverId: audioObject["receiverId"] as! String, audio: audioObject["audio"] as! NSData, audioDescription: audioObject["description"] as? String, senderId: audioObject["senderId"] as! String)
        
        return receivedAudio
    }
    
    func acceptAudioAttempt(audio:AudioAttempt) {
        //colocando audioId aceito com o alarme correspondente
        let audioAttempt = PFObject(withoutDataWithClassName: "AudioAttempt", objectId: audio.objectId)
        audioAttempt.fetch()
        let _audio = AudioAttempt(PFAudioAttempt: audioAttempt)
        _audio.saveAudioInToTemporaryDir()
        for(var i = 0 ;i < AlarmDAO.sharedInstance().userAlarms.count; i++){
            var alarm = AlarmDAO.sharedInstance().userAlarms[i]
            if alarm.objectId == audio.alarmId {
                alarm.audioId = audio.objectId
                alarm.save()
                alarm.updateNotificationSound("updateNotificationSound")
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