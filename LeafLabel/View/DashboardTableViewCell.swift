//
//  DashboardTableViewCell.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/26/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    
    @IBOutlet var productName: UILabel!
    @IBOutlet var productID: UILabel!
    @IBOutlet var gramCount: UILabel!
    @IBOutlet var labelsPrinted: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
