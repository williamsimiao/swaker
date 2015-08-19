//
//  AudioAttemptCell.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class AudioAttemptCell: UITableViewCell {
    
    var audioAttempt:AudioAttempt!
    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var senderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func accept(sender: AnyObject) {
        AudioDAO.sharedInstance().acceptAudioAttempt(audioAttempt)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}