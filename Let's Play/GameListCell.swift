//
//  GameListCell.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class GameListCell: UITableViewCell {
    
    @IBOutlet weak var game: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var play: UIButton!
    
    @IBAction func Share(_ sender: UIButton) {
    }
    
    @IBAction func Play(_ sender: UIButton) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
