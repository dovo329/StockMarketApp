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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {

            return;
        }
        let url = "http://dev.markitondemand.com/Api/v2/Quote/json?symbol="+searchText
        
        Alamofire.request(url).responseJSON { response in
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
                    self.dataSource.removeAll()
                    let change = dict["Change"] as? Double ?? 0.0
                    self.dataSource.append(TitleDetailPair(title: "Change", detail:currencyFromDouble(change)))
    //                self.dataSource.append(TitleDetailPair(title: "Change %", detail:JSON["ChangePercent"]))
    //                self.dataSource.append(TitleDetailPair(title: "Change % YTD", detail:JSON["ChangePercentYTD"]))
    //                self.dataSource.append(TitleDetailPair(title: "Change YTD", detail:JSON["ChangeYTD"]))
    //                self.dataSource.append(TitleDetailPair(title: "High", detail:JSON["High"]))
                    self.tableView.reloadData()
                }
                
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
}
