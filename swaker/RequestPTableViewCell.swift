//
//  RequestPTableViewCell.swift
//  swaker
//
//  Created by Joao Paulo Lopes da Silva on 31/07/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class RequestPTableViewCell: UITableViewCell {
    
    var audioAttempt:AudioAttempt!
    
    @IBAction func accept(sender: AnyObject) {
        AudioDAO.sharedInstance().acceptAudioAttempt(audioAttempt)
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
