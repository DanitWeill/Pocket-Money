//
//  UserCell.swift
//  Pocket Money
//
//  Created by Danit on 02/02/2022.
//

import UIKit
import SwipeCellKit

class UserCell: SwipeTableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var color: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        color.layer.cornerRadius = self.frame.height / 4.0
        color.layer.masksToBounds = true
        
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
