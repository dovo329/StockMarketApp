//
//  GraphView.swift
//  StockMarketApp
//
//  Created by Douglas Voss on 11/8/17.
//  Copyright © 2017 VossWareLLC. All rights reserved.
//

import Foundation
import UIKit

class GraphView: UIView {
    
    var xCoords = [Double]()
    var yCoords = [Double]()
    
    required init?(coder aDecoder: NSCoder) {
        print("init coder \(aDecoder)")
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Unable to get core graphics context for GraphView")
            return
        }
        
        let backgroundColor = self.backgroundColor?.cgColor ?? UIColor.white.cgColor
        context.setFillColor(backgroundColor)
        context.fill(self.bounds)
        context.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.setLineWidth(1.0)
        
        let outlinePath = CGMutablePath()
        
        outlinePath.move(to: CGPoint(x: 0.0, y: 0.0))
        outlinePath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height/2.0))
        outlinePath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        outlinePath.addLine(to: CGPoint(x: 0.0, y: self.bounds.size.height))
        outlinePath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        
        context.setFillColor(UIColor.green.cgColor)
        context.addPath(outlinePath)
        context.fillPath()
        
        context.addPath(outlinePath)
        context.strokePath()        
    }
}
