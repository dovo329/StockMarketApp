//
//  LeftTitleRightDetailTableViewCell.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/30/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit


class LeftTitleRightDetailTableViewCell: UITableViewCell {
    
    struct Constants {
        static let DefaultHeight : CGFloat = 44.0
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
}
