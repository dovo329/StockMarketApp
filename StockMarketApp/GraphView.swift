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
        
        let fillPath = CGMutablePath()
        fillPath.move(to: CGPoint(x: 0.0, y: 0.0))
        fillPath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height/2.0))
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
        
        let topLinePath = CGMutablePath()
        topLinePath.move(to: CGPoint(x: 0.0 , y: 0.0))
        topLinePath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height/2.0))
        context.addPath(topLinePath)
        context.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.setLineWidth(5.0)
        context.strokePath()
    }
}
