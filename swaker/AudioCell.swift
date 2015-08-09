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
    @IBOutlet weak var playButton: UIButton!
    var audio:NSData!
    @IBOutlet weak var audioNameLabel: UILabel!
    var flag = true
    let pauseImage = UIImage(named: "pause")
    let playImage = UIImage(named: "play")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func switchButtonImage(sender: UIButton) {
        if flag {
            sender.setImage(pauseImage, forState: UIControlState.Normal)
        } else {
            sender.setImage(playImage, forState: UIControlState.Normal)
        }
        flag = !flag
    }
    
    func switchToPlay() {
        playButton.setImage(playImage, forState: .Normal)
        flag = !flag
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
