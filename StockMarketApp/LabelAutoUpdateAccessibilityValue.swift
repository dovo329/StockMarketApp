//
//  LabelAutoUpdateAccessibilityValue.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/9/17.
//  Copyright © 2017 VossWareLLC. All rights reserved.
//

import Foundation
import UIKit

class LabelAutoUpdateAccessibilityValue: UILabel {
    
    override var text: String? {
        didSet {
            self.accessibilityValue = text
        }
    }
}
