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
                    self.alertWithTitle(title: parseErrorTitle, message: "Nil Data", ackStr: "OK")
                    
                } catch ParseError.responseString {
                    self.alertWithTitle(title: parseErrorTitle, message: "Error with Response String", ackStr: "OK")
                    
                } catch ParseError.json {
                    self.alertWithTitle(title: parseErrorTitle, message: "Error with JSON", ackStr: "OK")
                    
                } catch ParseError.responseType {
                    self.alertWithTitle(title: parseErrorTitle, message: "Response Type", ackStr: "OK")
                    
                } catch ParseError.noResults {
                    self.alertWithTitle(title: parseErrorTitle, message: "No Results", ackStr: "OK")
                    
                } catch ParseError.invalidResponseDict {
                    self.alertWithTitle(title: parseErrorTitle, message: "Invalid Response Dict", ackStr: "OK")
                    
                } catch {
                    self.alertWithTitle(title: parseErrorTitle, message: "Unknown error: \(error)", ackStr: "OK")
                }

            })
        })
        
        task.resume()
    }

    
    func parseData(_ data:Data?) throws {
        guard let safeData = data else {
            throw ParseError.nilData
        }
        
        guard let responseString = String(data: safeData, encoding: String.Encoding.utf8) else {
            self.alertWithTitle(title: "Error Parsing Data", message: "", ackStr: "OK")
            throw ParseError.responseString
        }
        //print("responseString = \(responseString)")
        
        guard let response = self.convertJSONArrStringtoArray(text: responseString) else {
            throw ParseError.json
        }
        
        guard let responseArr = response as? NSArray else {
            throw ParseError.responseType
        }
        
        if (responseArr.count == 0) {
            self.symbolLbl.text = "Symbol:"
            self.companyNameLbl.text = "Company Name:"
            self.exchangeLbl.text = "Exchange:"

            throw ParseError.noResults
        }
        
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
        
        //print("response: \(responseArr)")
        //print("response[0]: \(responseArr[0])")
        if let responseDict = responseArr[0] as? NSDictionary {
            if let dict = responseDict as? [String: String] {
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
        } else {
            throw ParseError.invalidResponseDict
        }
    }
    
    
    func convertJSONArrStringtoArray(text: String) -> Any? {
        print("text: \(text)");
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func alertWithTitle(title: String, message: String, ackStr: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: ackStr, style: UIAlertActionStyle.default, handler:nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
