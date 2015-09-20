//
//  FriendsCell.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 08/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alarmBadge: UIView!
    @IBOutlet weak var alarmBagdeLabel: UILabel!
    var alarmBadgeValue: Int = 0 {
        didSet {
            alarmBagdeLabel.text = String(alarmBadgeValue)
            if alarmBadgeValue == 0 {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.alarmBadge.alpha = 0
                })
            } else {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.alarmBadge.alpha = 1
                })
            }
        }
    }
    var friend: User!
    var hasLoadedOnce: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideBadges()
    }

    func loadFriendInfo() {
        var counter = 0
        for alarm in AlarmDAO.sharedInstance().friendsAlarms {
            if alarm.setterId == friend.objectId {
                counter++
            }
        }
        alarmBadgeValue = counter
        if !hasLoadedOnce {
            alarmBadge.layer.cornerRadius = alarmBadge.frame.height / 2
            alarmBadge.clipsToBounds = true
            photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
            photoImageView.clipsToBounds = true
            if let photo = friend.photo {
                photoImageView.image = UIImage(data: photo)
            }
            else{
                photoImageView.image = UIImage(named: "userDefault.png")
  
            }
            
        }
        hasLoadedOnce = true
    }
    
    func hideBadges() {
        alarmBadge.alpha = 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
