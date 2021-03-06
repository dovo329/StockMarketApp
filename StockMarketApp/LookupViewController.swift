//
//  LookupViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit

class LookupViewController: UIViewController, UISearchBarDelegate {

    // example lookup get request
    //http://dev.markitondemand.com/Api/v2/Lookup/json?input=Microsoft
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var symbolLbl: LabelAutoUpdateAccessibilityValue!
    @IBOutlet weak var companyNameLbl: LabelAutoUpdateAccessibilityValue!
    @IBOutlet weak var exchangeLbl: LabelAutoUpdateAccessibilityValue!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // the first thing I want to do is wait for the search bar to enter something
        symbolLbl.accessibilityIdentifier = "LookupVC SymbolLbl 2"
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // okay now I need to start the spinner and make my network request
        
        guard let searchStr = searchBar.text else {
            simpleAlert(vc: self, title: NSLocalizedString("Please Enter Some Text To Search For", comment: "Alert title"), message: NSLocalizedString("text is nil", comment: "Alert message"), ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        
        doLookup(searchText: searchStr,
                 completion:
            {
                (alert: (title: String, message: String)?) -> Void in
                if let alert = alert {
                    simpleAlert(vc: self, title: alert.title, message: alert.message, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    return
                }
                //print("Successful")
            }
        )
    }
    
    func doLookup(searchText: String, completion: @escaping (_ alert: (String, String)?) -> Void) {
        
//        guard let encodedSearchStr = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            completion((title: NSLocalizedString("Failed to URL encode search string", comment: "Alert title"), message: ""))
//            return
//        }
//
//        let urlParameters = ["input": "\(encodedSearchStr)"]
//        let lookupURLStr = BaseURLStr + "Lookup/json?input=" + encodedSearchStr
//
//        guard let lookupURL = URL(string: lookupURLStr) else {
//            completion((title: NSLocalizedString("String to URL conversion failed", comment: "Alert title"), message: ""))
//            return
//        }

        guard let baseUrl = URL(string: BaseURLStr) else {
            completion((title: NSLocalizedString("Failed to create base URL", comment: "Alert title"), message: ""))
            return
        }
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            completion((title: NSLocalizedString("Failed to create components URL", comment: "Alert title"), message: ""))
            return
        }
        urlComponents.path +=  "Lookup/json"
        let urlParameters = ["input": "\(searchText)"]
        let queryItems = urlParameters.flatMap({ URLQueryItem(name: $0.key, value: $0.value) })
        urlComponents.queryItems = queryItems
        
        guard let lookupURL = urlComponents.url else {
            completion((title: NSLocalizedString("Failed to create lookup URL", comment: "Alert title"), message: ""))
            return
        }
        var request = URLRequest(url:lookupURL);
        request.httpMethod = "GET"
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        if let isLoading = spinner?.isAnimating {
            if isLoading {
                return
            }
        }
        spinner?.startAnimating()
        let task = URLSession.shared.dataTask(with: request, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            DispatchQueue.main.async {
                self.spinner?.stopAnimating()
                
                if let error = error {
                    completion((title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription))
                    return
                }
                
                do {
                    try self.parseData(data)
                    completion(nil)
                    
                } catch {
                    //let nsError = error as NSError
                    // need this to get at code and domain provided by the CustomNSError protocol,
                    // otherwise I only get the localizedDescription.  But that's all I need in this case
                    completion((title: NSLocalizedString("Parse Error", comment: "Alert title"), message: error.localizedDescription))
                }
            }
        })
        task.resume()
    }
    
    private let SymbolFieldPrefix = NSLocalizedString("Symbol: ", comment: "Stock data field title")
    private let CompanyNameFieldPrefix = NSLocalizedString("Company Name: ", comment: "Stock data field title")
    private let ExchangeFieldPrefix = NSLocalizedString("Exchange: ", comment: "Stock data field title")
    
    private func parseData(_ data:Data?) throws {
        /* response: (
         {
         Exchange = NYSE;
         Name = "L-3 Communications Holdings Inc";
         Symbol = LLL;
         },
         {
         Exchange = "BATS Trading Inc";
         Name = "L-3 Communications Holdings Inc";
         Symbol = LLL;
         },
         {
         Exchange = NASDAQ;
         Name = "Lululemon Athletica Inc";
         Symbol = LULU;
         }
         )
         */
        
        guard let safeData = data else {
            throw ParseError.nilData
        }
        
        let jsonObj : Any
        do {
            try jsonObj = JSONSerialization.jsonObject(with: safeData, options: [])
            
        } catch {
            throw error
        }
        
        guard let responseArr = jsonObj as? [Any] else {
            throw ParseError.responseType
        }
        
        if (responseArr.count == 0) {
            clearUI()

            throw ParseError.noResults
        }
        
        //throw ParseError.noResults.nsError()
        //throw NSError(domain: Bundle.main.bundleIdentifier!, code: ParseError.noResults.rawValue, userInfo: [NSLocalizedDescriptionKey: ParseError.noResults.localizedDescription])
        
        if let dict = responseArr[0] as? [String: String] {

            var symbolLblTxt = SymbolFieldPrefix;
            if let symbol = dict["Symbol"] {
                symbolLblTxt += symbol
            }
            self.symbolLbl?.text = symbolLblTxt
            
            var companyNameLblTxt = CompanyNameFieldPrefix;
            if let companyName = dict["Name"] {
                companyNameLblTxt += companyName
            }
            self.companyNameLbl?.text = companyNameLblTxt
            
            var exchangeLblTxt = ExchangeFieldPrefix;
            if let exchange = dict["Exchange"] {
                exchangeLblTxt += exchange
            }
            self.exchangeLbl?.text = exchangeLblTxt

        } else {
            throw ParseError.invalidResponseDict
        }
    }
    
    func clearUI() {
        self.symbolLbl.text = SymbolFieldPrefix
        self.companyNameLbl.text = CompanyNameFieldPrefix
        self.exchangeLbl.text = ExchangeFieldPrefix
    }
}
