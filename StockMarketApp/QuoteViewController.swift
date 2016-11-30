//
//  QuoteViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit

enum QuoteError : Error {
    case nilData
    case responseString
    case json
    case responseType
    case noResults
    case invalidResponseDict
    
    var description: String {
        switch self {
        case .nilData:
            return "Nil Data"
        case .responseString:
            return "Error with Response String"
        case .json:
            return "Error with JSON"
        case .responseType:
            return "Response Type"
        case .noResults:
            return "No Results"
        case .invalidResponseDict:
            return "Invalid Response Dict"
            //default:
            //    return "Unknown Error"
        }
    }
}


class QuoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let CellId : String = "cell.id"
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "LeftTitleRightDetailTableViewCell", bundle: nil), forCellReuseIdentifier: CellId)
        
        dataSource.append("Test 1")
        dataSource.append("Test 2")
        dataSource.append("Test 3")
    }

    /*
     // http://dev.markitondemand.com/Api/v2/Quote?symbol=LLL

     {
    "Status": "SUCCESS",
    "Name": "L-3 Communications Holdings Inc",
    "Symbol": "LLL",
    "LastPrice": 158.63,
    "Change": 2.11,
    "ChangePercent": 1.348070534117,
    "Timestamp": "Tue Nov 29 00:00:00 UTC-05:00 2016",
    "MSDate": 42703,
    "MarketCap": 12263526670,
    "Volume": 7038,
    "ChangeYTD": 119.51,
    "ChangePercentYTD": 32.733662455025,
    "High": 158.86,
    "Low": 155.83,
    "Open": 156.6
    }*/
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableView.dequeueReusableCell(withIdentifier: CellId, for: indexPath)
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let c = cell as? LeftTitleRightDetailTableViewCell
        c?.title.text = dataSource[indexPath.row]
        c?.detail.text = "detail \(indexPath.row)"
    }
}
