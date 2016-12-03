//
//  QuoteViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit
import Alamofire

enum QuoteError : Error {
    case someError
    
    var description: String {
        switch self {
        case .someError:
            return "Some Error"
        }
    }
}


class QuoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    let CellId : String = "cell.id"
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [String]()
    //var opQ = OperationQueue()
    
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {

            return;
        }
        let testURL = "http://dev.markitondemand.com/Api/v2/Quote/json?symbol="+searchText
        
        Alamofire.request(testURL).responseJSON { response in
//            print(response.request)  // original URL request
//            print(response.response) // HTTP URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }
    
    
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
    
    func alertWithTitle(title: String, message: String, ackStr: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: ackStr, style: UIAlertActionStyle.default, handler:nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
