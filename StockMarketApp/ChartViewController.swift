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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: NSLocalizedString("Please enter some search text", comment: "Alert message"), ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return;
        }
        
        guard let baseUrl = URL(string: BaseURLStr) else {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to create base URL", comment: "Alert title"), message:"", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        guard var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true) else {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to create components URL", comment: "Alert title"), message:"", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        urlComponents.path += "InteractiveChart/json"
        // could I do a JSON serialization of a dictionary here?
        // Probably, and I should
        let elementsDict: [String: Any] =
        [
            "Symbol": searchText,
            "Type": "price",
            "Params": ["c"]
        ]
        let queryParamsDict: [String: Any] =
        [
            "Normalized": "false",
            "NumberOfDays": 365,
            "DataPeriod": "Day",
            "Elements": [elementsDict]
        ]
        
        let queryData: Data
        do {
            queryData = try JSONSerialization.data(withJSONObject: queryParamsDict, options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to create JSON data", comment: "Alert title"), message:"", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        guard let queryStr = String(data: queryData, encoding: String.Encoding.utf8) else {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to create JSON string", comment: "Alert title"), message:"", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }

        let urlParameters = ["parameters": queryStr]
        let queryItems = urlParameters.flatMap({ URLQueryItem(name: $0.key, value: $0.value) })
        urlComponents.queryItems = queryItems
        guard let chartURL = urlComponents.url else {
            simpleAlert(vc: self, title: NSLocalizedString("Failed to create quote URL", comment: "Alert title"), message:"", ackStr: NSLocalizedString("OK", comment: "Alert button"))
            return
        }
        var request = URLRequest(url:chartURL);
        request.httpMethod = "GET"
        
        //dismiss keyboard
        self.view.endEditing(true)
        if self.spinner.isAnimating {
            return
        }
        self.spinner.startAnimating()
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            DispatchQueue.main.async{
                self.spinner.stopAnimating()
                if let error = error {
                    simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                    return
                }
                
                do {
                    try self.parseData(data)
                } catch {
                    simpleAlert(vc: self, title: NSLocalizedString("Error", comment: "Alert title"), message: error.localizedDescription, ackStr: NSLocalizedString("OK", comment: "Alert button"))
                }
            }
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
        
        let responseStr = String(data: safeData, encoding: .utf8)
        
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
        
//        guard let datesArr = jsonDict["Dates"] as? [String]
//            else {
//                throw ParseError.invalidResponseDict
//        }
        
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
