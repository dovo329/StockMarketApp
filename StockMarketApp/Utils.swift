//
//  Utils.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 12/3/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import Foundation
import UIKit

func simpleAlert(vc: UIViewController, title: String, message: String, ackStr: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: ackStr, style: UIAlertActionStyle.default, handler:nil)
    alertController.addAction(okAction)
    vc.present(alertController, animated: true, completion: nil)
}

func currencyFromDouble(_ arg: Double) -> String {
    let num = NSNumber(value: arg)
    let str = NumberFormatter.localizedString(from: num, number: NumberFormatter.Style.currency)
    return str
}
