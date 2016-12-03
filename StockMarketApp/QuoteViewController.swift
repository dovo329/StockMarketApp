//
//  QuoteViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit

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
        
//        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://google.com/"]];
//        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
//        path:@"http://google.com/api/pigs/"
//        parameters:nil];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        
//        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
//        
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        // Print the response body in text
//        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
//        
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        }];
//        [operation start];
        
//        NSOperationQueue *networkQueue = [[NSOperationQueue alloc] init];
//        
//        networkQueue.maxConcurrentOperationCount = 5;
//        
//        NSURL *url = [NSURL URLWithString:@"https://example.com"];
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
//        initWithRequest:request];
//        
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        
//        NSLog(@"%@", string);
//        
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
//        }];
//        [networkQueue addOperation:operation];
        
        //var opQ = OperationQueue()
        //opQ.maxConcurrentOperationCount = 1
        //let url = URL(string: "http://dev.markitondemand.com/Api/v2/Quote?symbol=LLL")
        
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
}
