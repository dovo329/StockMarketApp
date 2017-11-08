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
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var exchangeLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // the first thing I want to do is wait for the search bar to enter something
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // okay now I need to start the spinner and make my network request
        
        guard let searchStr = searchBar.text else {
            simpleAlert(vc: self, title: NSLocalizedString("Please Enter Some Text To Search For", comment: "Alert title"), message: NSLocalizedString("text is nil", comment: "Alert message"), ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        
        guard let encodedSearchStr = searchStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to URL encode search string", comment: "Alert title"), message: "", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        
        let lookupURLStr = BaseURLStr + "Lookup/json?input=" + encodedSearchStr
        
        guard let lookupURL = URL(string: lookupURLStr) else {
            simpleAlert(vc: self, title: NSLocalizedString("String to URL conversion failed", comment: "Alert title"), message: "", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        var request = URLRequest(url:lookupURL);
        request.httpMethod = "GET"
        
        // dismiss keyboard
        self.view.endEditing(true)
        
        spinner.startAnimating()
        let task = URLSession.shared.dataTask(with: request, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            DispatchQueue.main.async( execute: {
                self.spinner.stopAnimating()
            
                if let error = error {
                    simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    return
                }

                let parseErrorTitle = NSLocalizedString("Parse Error", comment: "Alert title");
                do {
                    try self.parseData(data)
                    
                } catch ParseError.nilData {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.nilData.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch ParseError.responseString {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.responseString.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch ParseError.json {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.json.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch ParseError.responseType {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.responseType.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch ParseError.noResults {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.noResults.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch ParseError.invalidResponseDict {
                    simpleAlert(vc: self, title: parseErrorTitle, message: ParseError.invalidResponseDict.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    
                } catch {
                    simpleAlert(vc: self, title: parseErrorTitle, message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
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
            self.symbolLbl.text = symbolLblTxt
            
            var companyNameLblTxt = CompanyNameFieldPrefix;
            if let companyName = dict["Name"] {
                companyNameLblTxt += companyName
            }
            self.companyNameLbl.text = companyNameLblTxt
            
            var exchangeLblTxt = ExchangeFieldPrefix;
            if let exchange = dict["Exchange"] {
                exchangeLblTxt += exchange
            }
            self.exchangeLbl.text = exchangeLblTxt

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
