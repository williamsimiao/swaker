//
//  AudioCell.swift
//  swaker
//
//  Created by William on 8/2/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit
import AVFoundation


class AudioCell: UITableViewCell {
    var audio:NSData!

    @IBAction func PlayButton(sender: AnyObject) {
        var error:NSError?
        
//        audioPlayer = AVAudioPlayer(contentsOfURL: <#NSURL!#>, error: error)
//        audioPlayer.play()
    }
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?, path: String) {
//        let decoder = 
//        let audio = AudioSaved()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
