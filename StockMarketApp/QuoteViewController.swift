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
        
//        dataSource.append(TitleDetailPair(title: "Title 1", detail: "Detail 1"))
//        dataSource.append(TitleDetailPair(title: "Title 2", detail: "Detail 2"))
//        dataSource.append(TitleDetailPair(title: "Title 3", detail: "Detail 3"))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchStr = searchBar.text else {
            simpleAlert(vc: self, title: "Please Enter Some Text To Search For", message: "text is nil", ackStr: "OK")
            return
        }
        
        guard let encodedSearchStr = searchStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            simpleAlert(vc: self, title: "Failed to URL encode search string", message: "", ackStr: "OK")
            return
        }
        
        let url = "http://dev.markitondemand.com/Api/v2/Quote/json?symbol="+encodedSearchStr
        
        self.view.endEditing(true)
        
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
//                {
//                    "Status": "SUCCESS",
//                    "Name": "L3 Technologies Inc",
//                    "Symbol": "LLL",
//                    "LastPrice": 186.1,
//                    "Change": -0.300000000000011,
//                    "ChangePercent": -0.16094420600859,
//                    "Timestamp": "Tue Nov 7 16:02:01 UTC-05:00 2017",
//                    "MSDate": 43046.6680671296,
//                    "MarketCap": 14542226200,
//                    "Volume": 503375,
//                    "ChangeYTD": 152.11,
//                    "ChangePercentYTD": 22.345670896062,
//                    "High": 187.9,
//                    "Low": 185.57,
//                    "Open": 186.41
//                }
                if let dict = JSON as? [String: Any] {

                    if let errorMessage = dict["Message"] as? String {
                        simpleAlert(vc: self, title: "Error", message: errorMessage, ackStr: "OK")
                        
                    } else {
                        
                        self.dataSource.append(TitleDetailPair(title: "Name", detail:safeString(dict["Name"])))
                        self.dataSource.append(TitleDetailPair(title: "Symbol", detail:safeString(dict["Symbol"])))
                        self.dataSource.append(TitleDetailPair(title: "LastPrice", detail:self.toCurrencyStr(dict["LastPrice"])))
                        self.dataSource.append(TitleDetailPair(title: "Change", detail:self.toCurrencyStr(dict["Change"])))
                        self.dataSource.append(TitleDetailPair(title: "Change %", detail:self.toPercentStr(dict["ChangePercent"])))
                        self.dataSource.append(TitleDetailPair(title: "Timestamp", detail:safeString(dict["Timestamp"])))
                        self.dataSource.append(TitleDetailPair(title: "MSDate", detail:toDoubleStr(dict["MSDate"])))
                        self.dataSource.append(TitleDetailPair(title: "MarketCap", detail:self.toCurrencyStr(dict["MarketCap"])))
                        self.dataSource.append(TitleDetailPair(title: "Volume", detail:anyToIntString(dict["Volume"])))
                        self.dataSource.append(TitleDetailPair(title: "Change YTD", detail:self.toCurrencyStr(dict["ChangeYTD"])))
                        self.dataSource.append(TitleDetailPair(title: "Change % YTD", detail:self.toPercentStr(dict["ChangePercentYTD"])))
                        self.dataSource.append(TitleDetailPair(title: "High", detail:self.toCurrencyStr(dict["High"])))
                        self.dataSource.append(TitleDetailPair(title: "Low", detail:self.toCurrencyStr(dict["Low"])))
                        self.dataSource.append(TitleDetailPair(title: "Open", detail:self.toCurrencyStr(dict["Open"])))

                        self.tableView.reloadData()
                    }
                    
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
    
    func toPercentStr(_ arg: Any?) -> String {
        let percent = arg as? Double ?? 0.0
        return percentFromDouble(percent)
    }
}
