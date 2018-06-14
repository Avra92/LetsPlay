//
//  FriendViewCell.swift
//  Let's Play
//
//  Created by Avra Ghosh on 13/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {

    @IBOutlet weak var gameIcon: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var f_userName: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
