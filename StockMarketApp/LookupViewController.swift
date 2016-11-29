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


class LookupViewController: UIViewController, UISearchBarDelegate {

    // example lookup get request
    //http://dev.markitondemand.com/Api/v2/Lookup/json?input=Microsoft
    let baseURLStr : String = "http://dev.markitondemand.com/Api/v2/";
    
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
            self.alertWithTitle(title: "Please Enter Some Text To Search For", message: "text is nil", ackStr: "OK")
            return
        }
        
        guard let encodedSearchStr = searchStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            self.alertWithTitle(title: "Failed to URL encode search string", message: "", ackStr: "OK")
            return
        }
        
        let lookupURLStr = baseURLStr + "Lookup/json?input=" + encodedSearchStr
        
        guard let lookupURL = URL(string: lookupURLStr) else {
            self.alertWithTitle(title: "String to URL conversion failed", message: "", ackStr: "OK")
            return
        }
        var request = URLRequest(url:lookupURL);
        request.httpMethod = "GET"
        
        spinner.startAnimating()
        let task = URLSession.shared.dataTask(with: request, completionHandler:{ (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            DispatchQueue.main.async( execute: {
                self.spinner.stopAnimating()
            
                if let error = error {
                    self.alertWithTitle(title: error.localizedDescription, message: "", ackStr: "OK")
                    return
                }

                let parseErrorTitle = "Parse Error";
                do {
                    try self.parseData(data)
                    
                } catch ParseError.nilData {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.nilData.description, ackStr: "OK")
                    
                } catch ParseError.responseString {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.responseString.description, ackStr: "OK")
                    
                } catch ParseError.json {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.json.description, ackStr: "OK")
                    
                } catch ParseError.responseType {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.responseType.description, ackStr: "OK")
                    
                } catch ParseError.noResults {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.noResults.description, ackStr: "OK")
                    
                } catch ParseError.invalidResponseDict {
                    self.alertWithTitle(title: parseErrorTitle, message: ParseError.invalidResponseDict.description, ackStr: "OK")
                    
                } catch {
                    self.alertWithTitle(title: parseErrorTitle, message: "Unknown error: \(error)", ackStr: "OK")
                }

            })
        })
        
        task.resume()
    }
    
    
    func parseData(_ data:Data?) throws {
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
            
        } catch let error as NSError {
            
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

            if let symbolStr = dict["Symbol"] {
                self.symbolLbl.text = "Symbol: " + symbolStr
            }
            if let companyNameStr = dict["Name"] {
                self.companyNameLbl.text = "Company Name: " + companyNameStr
            }
            if let exchangeStr = dict["Exchange"] {
                self.exchangeLbl.text = "Exchange: " + exchangeStr
            }

        } else {
            throw ParseError.invalidResponseDict
        }
    }
    
    
    func clearUI() {
        self.symbolLbl.text = "Symbol: "
        self.companyNameLbl.text = "Company Name: "
        self.exchangeLbl.text = "Exchange: "
    }
    
    
    func alertWithTitle(title: String, message: String, ackStr: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: ackStr, style: UIAlertActionStyle.default, handler:nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
