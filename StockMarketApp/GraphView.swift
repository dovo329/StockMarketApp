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
    
    var xCoords = [Double]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var yCoords = [Double]() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
//    var xCoords : [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
//    var yCoords : [Double] = [0.0, 0.5, 1.0, 0.25, 0.1]
    
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
        
        let linePath = CGMutablePath()

        //let yMax = yCoords.max() ?? 1.0
        let iThresh = min(yCoords.count, xCoords.count)
        if (iThresh > 0) {
            for i in 0..<iThresh {
                let viewX = xCoords[i] * Double(self.bounds.size.width)
                let viewY = (yCoords[i] * (-Double(self.bounds.size.height))) + Double(self.bounds.size.height)
                
                let viewPt = CGPoint(x: viewX, y: viewY)
                if i==0 {
                    linePath.move(to: viewPt)
                } else {
                    linePath.addLine(to: viewPt)
                }
            }
            
            guard let fillPath = linePath.mutableCopy() else {
                assertionFailure("Unable to create fill path for GraphView")
                return
            }
            fillPath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
            fillPath.addLine(to: CGPoint(x: 0.0, y: self.bounds.size.height))
            fillPath.closeSubpath()
            
            context.saveGState()
            context.addPath(fillPath)
            context.clip()
            //context.fillPath()
            let gradientColorArr = [UIColor.green.cgColor, UIColor.blue.cgColor] as CFArray
            let locationsArr: [CGFloat] = [0.0, 1.0]
            guard let gradient = CGGradient(colorsSpace: context.colorSpace, colors: gradientColorArr, locations: locationsArr) else {
                assertionFailure("Unable to create gradient for GraphView")
                return
            }
            context.drawLinearGradient(gradient, start: CGPoint(x:0.0, y:0.0), end: CGPoint(x:0.0, y: self.bounds.size.height), options: CGGradientDrawingOptions())
            context.restoreGState()
            
            context.addPath(linePath)
            context.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            context.setLineWidth(5.0)
            context.strokePath()
        }
    }
}
