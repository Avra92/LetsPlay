//
//  StatViewCell.swift
//  Let's Play
//
//  Created by Avra Ghosh on 11/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class StatViewCell: UITableViewCell {

    @IBOutlet weak var statDetail: UILabel!
    @IBOutlet weak var statValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
