//
//  LookupViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit


enum ParseError : Error {
    case nilData
    case responseString
    case json
    case responseType
    case noResults
    case invalidResponseDict
    
    var localizedDescription: String {
        switch self {
        case .nilData:
            return NSLocalizedString("Nil Data", comment: "Parse Error")
        case .responseString:
            return NSLocalizedString("Error with Response String", comment: "Parse Error")
        case .json:
            return NSLocalizedString("Error with JSON", comment: "Parse Error")
        case .responseType:
            return NSLocalizedString("Response Type", comment: "Parse Error")
        case .noResults:
            return NSLocalizedString("No Results", comment: "Parse Error")
        case .invalidResponseDict:
            return NSLocalizedString("Invalid Response Dict", comment: "Parse Error")
        }
    }
}


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
                print("Successful")
            }
        )
    }
    
    func doLookup(searchText: String, completion: @escaping (_ alert: (String, String)?) -> Void) {
        
//        completion(nil)
//        return
        
//        completion((title: "Test completion title", message: "Test completion message"))
//        return
        
        guard let encodedSearchStr = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion((title: NSLocalizedString("Failed to URL encode search string", comment: "Alert title"), message: ""))
            return
        }
        
        let lookupURLStr = BaseURLStr + "Lookup/json?input=" + encodedSearchStr
        
        guard let lookupURL = URL(string: lookupURLStr) else {
            completion((title: NSLocalizedString("String to URL conversion failed", comment: "Alert title"), message: ""))
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
            
            DispatchQueue.main.async( execute: {
                self.spinner?.stopAnimating()
                
                if let error = error {
                    completion((title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription))
                    return
                }
                
                let parseErrorTitle = NSLocalizedString("Parse Error", comment: "Alert title");
                do {
                    try self.parseData(data)
                    completion(nil)
                    
                } catch ParseError.nilData {
                    completion((title: parseErrorTitle, message: ParseError.nilData.localizedDescription))
                    return
                    
                } catch ParseError.responseString {
                    completion((title: parseErrorTitle, message: ParseError.responseString.localizedDescription))
                    return
                    
                } catch ParseError.json {
                    completion((title: parseErrorTitle, message: ParseError.json.localizedDescription))
                    return
                    
                } catch ParseError.responseType {
                    completion((title: parseErrorTitle, message: ParseError.responseType.localizedDescription))
                    return
                    
                } catch ParseError.noResults {
                    completion((title: parseErrorTitle, message: ParseError.noResults.localizedDescription))
                    return
                    
                } catch ParseError.invalidResponseDict {
                    completion((title: parseErrorTitle, message: ParseError.invalidResponseDict.localizedDescription))
                    return
                    
                } catch {
                    completion((title: parseErrorTitle, message: error.localizedDescription))
                    return
                }
            })
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
            
        //} catch let error as NSError {
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
        
        if let dict = responseArr[0] as? [String: String] {

            var symbolLblTxt = SymbolFieldPrefix;
            if let symbol = dict["Symbol"] {
                symbolLblTxt += symbol
            }
            self.symbolLbl?.text = symbolLblTxt
            //self.symbolLbl?.accessibilityValue = symbolLblTxt
            
            var companyNameLblTxt = CompanyNameFieldPrefix;
            if let companyName = dict["Name"] {
                companyNameLblTxt += companyName
            }
            self.companyNameLbl?.text = companyNameLblTxt
            //self.companyNameLbl.accessibilityValue = companyNameLblTxt
            
            var exchangeLblTxt = ExchangeFieldPrefix;
            if let exchange = dict["Exchange"] {
                exchangeLblTxt += exchange
            }
            self.exchangeLbl?.text = exchangeLblTxt
            //self.exchangeLbl.accessibilityValue = exchangeLblTxt

        } else {
            throw ParseError.invalidResponseDict
        }
    }
    
    func clearUI() {
        self.symbolLbl.text = SymbolFieldPrefix
        //self.symbolLbl.accessibilityValue = SymbolFieldPrefix
        
        self.companyNameLbl.text = CompanyNameFieldPrefix
        //self.companyNameLbl.accessibilityValue = CompanyNameFieldPrefix
        
        self.exchangeLbl.text = ExchangeFieldPrefix
        //self.exchangeLbl.accessibilityValue = ExchangeFieldPrefix
    }
}
