//
//  TextFieldCell.swift
//  swaker
//
//  Created by André Marques da Silva Rodrigues on 09/08/15.
//  Copyright (c) 2015 William. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
