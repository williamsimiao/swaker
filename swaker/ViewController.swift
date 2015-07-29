//
//  ViewController.swift
//  swaker
//
//  Created by William on 7/24/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var test = AudioDAO.sharedInstance()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        
        let soundFilePath = docsDir.stringByAppendingPathComponent("texto")
        println("\(soundFilePath)")
        let text = "oi"
        text.writeToFile(soundFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let data = NSData(contentsOfURL: soundFileURL!)
        
        var lala = AudioAttempt(alarmId: "teste1", audio: data, audioDescription: "minha record", senderId: "william")
        
        lala.SaveAudioInToLibrary()
        
        let muitodoido = test.addAudioAttempt(lala)!
        
        let tipoSaved = lala.convertToSaved()
        
      
        tipoSaved.SaveAudioInToLibrary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

