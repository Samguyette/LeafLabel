//
//  ProductViewCellTableViewCell.swift
//  LeafLabel
//
//  Created by Sam Guyette on 10/15/19.
//  Copyright © 2019 Sam Guyette. All rights reserved.
//

import UIKit

class ProductViewCellTableViewCell: UITableViewCell {

    @IBOutlet var productName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
