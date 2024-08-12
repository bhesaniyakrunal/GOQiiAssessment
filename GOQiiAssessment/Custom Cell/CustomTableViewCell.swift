//
//  CustomTableViewCell.swift
//  GOQiiAssessment
//
//  Created by MacBook on 8/12/24.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
