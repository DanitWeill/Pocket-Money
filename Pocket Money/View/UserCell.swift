//
//  UserCell.swift
//  Pocket Money
//
//  Created by Danit on 02/02/2022.
//

import UIKit
import SwipeCellKit

class UserCell: SwipeTableViewCell {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var color: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        color.layer.cornerRadius = self.frame.height / 6.0
        color.layer.masksToBounds = true
     
        
        userPicture.layer.cornerRadius = userPicture.frame.size.width/2
        userPicture.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
