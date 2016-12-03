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
    
    @IBOutlet weak var tableSpinner: UIActivityIndicatorView!
    
    struct TitleDetailPair {
        var title = ""
        var detail = ""
    }
    
    var dataSource = [TitleDetailPair]()
    //var opQ = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "LeftTitleRightDetailTableViewCell", bundle: nil), forCellReuseIdentifier: CellId)
        
        dataSource.append(TitleDetailPair(title: "Title 1", detail: "Detail 1"))
        dataSource.append(TitleDetailPair(title: "Title 2", detail: "Detail 2"))
        dataSource.append(TitleDetailPair(title: "Title 3", detail: "Detail 3"))
    }
    
    // Why won't it recognize this?
//    func toCurrentStr(_ arg: Any) -> String {
//        let currency = arg as? Double ?? 0.0
//        return currencyFromDouble(currency)
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {

            return;
        }
        let url = "http://dev.markitondemand.com/Api/v2/Quote/json?symbol="+searchText
        
        tableSpinner.startAnimating()
        dataSource.removeAll()
        self.tableView.reloadData()
        Alamofire.request(url).responseJSON { response in
            self.tableSpinner.stopAnimating()
//            print(response.request)  // original URL request
//            print(response.response) // HTTP URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                
                print("JSON: \(JSON)")
                // this is example of what I get back:
//                JSON: {
//                    Change = "-0.260000000000019";
//                    ChangePercent = "-0.165089846974423";
//                    ChangePercentYTD = "31.5622123671659";
//                    ChangeYTD = "119.51";
//                    High = "157.9";
//                    LastPrice = "157.23";
//                    Low = "156.64";
//                    MSDate = "42706.6680555556";
//                    MarketCap = 12155294070;
//                    Name = "L-3 Communications Holdings Inc";
//                    Open = "157.44";
//                    Status = SUCCESS;
//                    Symbol = LLL;
//                    Timestamp = "Fri Dec 2 16:02:00 UTC-05:00 2016";
//                    Volume = 511958;
//                }
                if let dict = JSON as? NSDictionary {

                    self.dataSource.append(TitleDetailPair(title: "Change", detail:self.toCurrencyStr(dict["Change"])))
                    self.dataSource.append(TitleDetailPair(title: "Change %", detail:self.toCurrencyStr(dict["ChangePercent"])))
                    self.dataSource.append(TitleDetailPair(title: "Change % YTD", detail:self.toCurrencyStr(dict["ChangeYTD"])))
                    self.dataSource.append(TitleDetailPair(title: "High", detail:self.toCurrencyStr(dict["High"])))
                    self.dataSource.append(TitleDetailPair(title: "LastPrice", detail:self.toCurrencyStr(dict["LastPrice"])))
                    self.dataSource.append(TitleDetailPair(title: "Low", detail:self.toCurrencyStr(dict["Low"])))

                    self.tableView.reloadData()
                    
                } else {
                    simpleAlert(vc: self, title: "JSON Parse Error", message: "", ackStr: "OK")
                }
                
            } else {
                simpleAlert(vc: self, title: response.result.error?.localizedDescription ?? "Error", message: "", ackStr: "OK")
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
        
        let ds = dataSource[indexPath.row]
        c?.title.text = ds.title
        c?.detail.text = ds.detail
    }
    
    func toCurrencyStr(_ arg: Any?) -> String {
        let currency = arg as? Double ?? 0.0
        return currencyFromDouble(currency)
    }
}
