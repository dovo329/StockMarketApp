//
//  Utils.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 12/3/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import Foundation
import UIKit

let BaseURLStr : String = "http://dev.markitondemand.com/Api/v2/";

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

func percentFromDouble(_ arg: Double) -> String {
    let num = NSNumber(value: arg)
    let str = NumberFormatter.localizedString(from: num, number: NumberFormatter.Style.percent)
    return str
}

func toDoubleStr(_ arg: Any?) -> String {
    let argDouble = arg as? Double ?? 0.0
    let num = NSNumber(value: argDouble)
    let str = NumberFormatter.localizedString(from: num, number: NumberFormatter.Style.decimal)
    return str
}

func safeString(_ arg: Any?) -> String {
    let returnStr = arg as? String ?? ""
    return returnStr
}

func anyToIntString(_ arg: Any?) -> String {
    let argInt = arg as? Int ?? 0
    let num = NSNumber(value: argInt)
    let str = NumberFormatter.localizedString(from: num, number: NumberFormatter.Style.none)
    return str
}
