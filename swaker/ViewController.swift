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
        var test = AudioDAO.sharedInstance()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
      
        let soundFilePath = docsDir.stringByAppendingPathComponent("texto")
        let text = "oi"
        text.writeToFile(soundFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let data = NSData(contentsOfURL: soundFileURL!)
        var lala = AudioAttempt(alarmId: "teste1", audio: data, audioDescription: "minha record", senderId: "william")

        let muitodoido = test.addAudioAttempt(lala) as PFObject
        println("audioId:\(lala.audioId)")
        
        println("oi")
        
        test.deleteAudioAttempt(muitodoido)

        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

