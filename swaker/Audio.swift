//
//  Audio.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 27/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class Audio: NSObject {
    var audio:NSData!
    var audioDescription:String?
    var senderId:String!
    var audioId: String!
    
    init(audio:NSData!, audioDescription:String?, senderId:String!) {
        
        
        self.audio = audio
        self.audioDescription = audioDescription
        self.senderId = senderId
        
        
    }
    
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
        Checa se existe um driretorio 'directoryPath' na pasta documents, caso nao exista cria
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
        println("\(fullPath)")
        return fullPath
    }
}

