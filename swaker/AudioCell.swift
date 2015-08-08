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

    @IBOutlet weak var playButton: UIButton!
    @IBAction func PlayButton(sender: AnyObject) {
        var error:NSError?
        let  tableview  = self.superview?.superview as! UITableView
        let controller = tableview.dataSource as! AudioSelectionTableViewController
        controller.audioPlayer = AVAudioPlayer(data: audio, error: &error)
        
        controller.audioPlayer.play()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
               // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
