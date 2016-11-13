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
            let alertController = UIAlertController(title: "Please Enter Some Text To Search For", message: "text is nil", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let encodedSearchStr = searchStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            assert(false, "encodedSearchStr is nil")
            return
        }
        
        let lookupURLStr = baseURLStr + "Lookup/json?input=" + encodedSearchStr

        
        let lookupURLOpt = URL(string: lookupURLStr);
        guard let lookupURL = lookupURLOpt else {
            assert(false, "lookupURL is nil")
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

                guard let safeData = data else {
                    self.alertWithTitle(title: "Data Is Nil", message: "", ackStr: "OK")
                    return
                }
                guard let responseString = String(data: safeData, encoding: String.Encoding.utf8) else {
                    self.alertWithTitle(title: "Error Parsing Data", message: "", ackStr: "OK")
                    return
                }
                print("responseString = \(responseString)")
            
                /*let stringLen : Int = testStr.characters.count;

                
                let startIndex = testStr.index(testStr.startIndex, offsetBy: 1)
                let endIndex = testStr.index(testStr.endIndex, offsetBy: -1)
                

                guard let jsonResponseString = responseString?.substring(with: startIndex..<endIndex) else {
                    print("oh no!")
                    return
                }*/
            

                // Convert server json response to NSDictionary

//                let str = "{\"name\":\"James\"}"
//                if let result = self.convertJSONArrStringtoArray(text: str) {
//                    print("example: \(result)")
//                }
            
                guard let response = self.convertJSONArrStringtoArray(text: responseString) else {
                    self.alertWithTitle(title: "Error Parsing JSON", message: "", ackStr: "OK")
                    return
                }
                
                //if let arr = response as? [Any] {
                    //print("arr: \(arr)")
                //}
                
                guard let responseArr = response as? NSArray else {
                    return
                }

                if (responseArr.count == 0) {
                    self.symbolLbl.text = "Symbol:"
                    self.companyNameLbl.text = "Company Name:"
                    self.exchangeLbl.text = "Exchange:"
                    self.alertWithTitle(title: "No Results Found", message: "For "+searchStr, ackStr: "OK")
                    return
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
                    }
                }
            })
        })
        
        task.resume()
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
