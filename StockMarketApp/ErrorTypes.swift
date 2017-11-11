//
//  ErrorTypes.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/10/17.
//  Copyright © 2017 VossWareLLC. All rights reserved.
//

import Foundation

enum ParseError : Int, CustomNSError, LocalizedError {
    // raw value is the error code
    case nilData = 0
    case responseString
    case json
    case responseType
    case noResults
    case invalidResponseDict
    
    var errorDescription: String {
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
    
    var errorDomain: String {
        return Bundle.main.bundleIdentifier! + ".ParseError"
    }
    
    var errorCode: Int {
        return self.rawValue
    }
    
    var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey: self.errorDescription]
    }
    
//    func nsError() -> NSError {
//        return NSError(domain: Bundle.main.bundleIdentifier! + ".ParseError", code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: self.localizedDescription])
//    }
}
