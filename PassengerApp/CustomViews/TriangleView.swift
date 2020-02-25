//
//  TriangleView.swift
//  PassengerApp
//
//  Created by iphone3 on 15/08/18.
//  Copyright © 2018 V3Cube. All rights reserved.
//

import UIKit


class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: (rect.maxY / 2.0)))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.closePath()
        
        //        It will draw linke this >
        //        This will start from MinX, MaxY;
        //        Draw a line from the start to MaxX, MaxY / 2.0;
        //        Draw a line from MaxX,MaxY / 2.0 to MinX, MinY;
        //        Then close the path to the start location.
        
        context.setFillColor(UIColor.UCAColor.AppThemeColor.cgColor)
        context.fillPath()
    }
}
