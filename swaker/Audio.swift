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
    var audioName: String!
    
    init(audio:NSData!, audioDescription:String?, senderId:String!) {
        
        self.audio = audio
        self.audioDescription = audioDescription
        self.senderId = senderId
        
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
}
