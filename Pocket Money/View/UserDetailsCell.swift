//
//  UserDetailsCell.swift
//  Pocket Money
//
//  Created by Danit on 13/02/2022.
//

import UIKit

class UserDetailsCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountAddedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        stackView.layer.cornerRadius = stackView.frame.size.height / 6.0
//        stackView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}