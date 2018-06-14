//
//  FriendViewCell.swift
//  Let's Play
//
//  Created by Avra Ghosh on 13/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class FriendViewCell: UITableViewCell {

    @IBOutlet weak var img_gameIcon: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var view_container: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
