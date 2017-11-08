//
//  ChartViewController.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/12/16.
//  Copyright © 2016 VossWareLLC. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: NSLocalizedString("Please enter some search text", comment: "Alert message"), ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return;
        }
        
        let urlStr = BaseURLStr + "InteractiveChart/json?" +
        "parameters={" +
            "\"Normalized\":false," +
            "\"NumberOfDays\":365," +
            "\"DataPeriod\":\"Day\"," +
            "\"Elements\":[{" +
            "\"Symbol\":\"LLL\"," +
            "\"Type\":\"price\"," +
            "\"Params\":[\"c\"]}]}"
        
        guard let urlPercentEncodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: urlPercentEncodedStr) else {
            simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: NSLocalizedString("Could not make url", comment: "Alert message"), ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return;
        }
        //var request = URLRequest(url: url);
        //request.httpMethod = "GET"
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        // http%3A%2F%2Fdev.markitondemand.com%2FApi%2Fv2%2FInteractiveChart%2Fjson%3F
        
        //parameters=%7B%22Normalized%22%3Afalse,%22NumberOfDays%22%3A365,%22DataPeriod%22%3A%22Day%22,%22Elements%22%3A%5B%7B%22Symbol%22%3A%22LLL%22,%22Type%22%3A%22price%22,%22Params%22%3A%5B%22c%22%5D%7D%5D%7D, NSErrorFailingURLKey=http%3A%2F%2Fdev.markitondemand.com%2FApi%2Fv2%2FInteractiveChart%2Fjson%3Fparameters=%7B%22Normalized%22%3Afalse,%22NumberOfDays%22%3A365,%22DataPeriod%22%3A%22Day%22,%22Elements%22%3A%5B%7B%22Symbol%22%3A%22LLL%22,%22Type%22%3A%22price%22,%22Params%22%3A%5B%22c%22%5D%7D%5D%7D
        
//        let headers = [
//            "cache-control": "no-cache",
//            "postman-token": "6921a2aa-319b-c544-297c-314d5e93dc7c"
//        ]
//
        var request = NSMutableURLRequest(url: URL(string: "http://dev.markitondemand.com/Api/v2/InteractiveChart/json?parameters=%7B%22Normalized%22%3Afalse%2C%22NumberOfDays%22%3A365%2C%22DataPeriod%22%3A%22Day%22%2C%22Elements%22%3A%5B%7B%22Symbol%22%3A%22LLL%22%2C%22Type%22%3A%22price%22%2C%22Params%22%3A%5B%22c%22%5D%7D%5D%7D")!)
        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//
//        let session = NSURLSession.sharedSession()
//        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                println(error)
//            } else {
//                let httpResponse = response as? NSHTTPURLResponse
//                println(httpResponse)
//            }
//        })
//
//        dataTask.resume()
        
        let task = URLSession.shared.dataTask(with: request as! URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            DispatchQueue.main.async( execute: {
                
                if let error = error {
                    simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    return
                }
                
                do {
                    try self.parseData(data)
                } catch {
                    simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                }
            })
        }
        task.resume()
    }
    
    private func parseData(_ data: Data?) throws {
        //    http://dev.markitondemand.com/Api/v2/InteractiveChart/json?parameters={
        //    "Normalized":false,
        //    "NumberOfDays":365,
        //    "DataPeriod":"Day",
        //    "Elements":[{
        //    "Symbol":"LLL",
        //    "Type":"price",
        //    "Params":["c"]}]}
        //
        //{
        //    "Labels": null,
        //    "Positions": [
        //    0,
        //    0.004,
        //
        //    "Dates": [
        //    "2016-11-08T00:00:00",
        //    "2016-11-09T00:00:00",
        //
        //    "Elements": [
        //    {
        //    "Currency": "USD",
        //    "TimeStamp": null,
        //    "Symbol": "LLL",
        //    "Type": "price",
        //    "DataSeries": {
        //    "close": {
        //    "min": 137.73,
        //    "max": 191.55,
        //    "maxDate": "2017-10-02T00:00:00",
        //    "minDate": "2016-11-08T00:00:00",
        //    "values": [
        //    137.73,
        //    148.35,
        
        guard let safeData = data else {
            throw ParseError.nilData
        }
        
        let jsonObj : Any
        do {
            try jsonObj = JSONSerialization.jsonObject(with: safeData, options: [])
        } catch {
            throw error
        }
        
        guard let jsonDict = jsonObj as? [String: Any]
            else {
                throw ParseError.responseType
        }
        
//        guard let positionsArr = jsonDict["Positions"] as? [Double],
//            let datesArr = jsonDict["Dates"] as? [Any],
//            let elementsDict = jsonDict["Elements"] as? [String: Any]
//            else {
//                throw ParseError.invalidResponseDict
//        }
        
        guard let positionsArr = jsonDict["Positions"] as? [Double]
            else {
                throw ParseError.invalidResponseDict
        }
        
        guard let datesArr = jsonDict["Dates"] as? [String]
            else {
                throw ParseError.invalidResponseDict
        }
        
        guard let elementsArr = jsonDict["Elements"] as? [Any]
            else {
                throw ParseError.invalidResponseDict
        }
        
        guard let elementsDict = elementsArr.first as? [String: Any]
            else {
                throw ParseError.invalidResponseDict
        }
        
        guard let dataSeriesDict = elementsDict["DataSeries"] as? [String: Any]
            else {
                throw ParseError.invalidResponseDict
        }
     
        guard let closeDict = dataSeriesDict["close"] as? [String: Any]
            else {
                throw ParseError.invalidResponseDict
        }
        
        guard let valuesArr = closeDict["values"] as? [Double]
            else {
                throw ParseError.invalidResponseDict
        }
        
        // now I have positionsArr, datesArr, and valuesArr that I can use to make the graph
        self.graphView.xCoords = positionsArr
        
        let maxValue = valuesArr.max() ?? 1.0
        var normalizedValuesArr = [Double]()
        for value in valuesArr {
            normalizedValuesArr.append(value/maxValue)
        }
        self.graphView.yCoords = normalizedValuesArr
    }
}
