//
//  GameListCell.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class GameListCell: UITableViewCell {

    @IBOutlet weak var lbl_game: UILabel!
    @IBOutlet weak var lbl_nickname: UILabel!
    @IBOutlet weak var btn_addFriends: UIButton!
    @IBOutlet weak var btn_letsPlay: UIButton!
    @IBOutlet weak var view_container: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
