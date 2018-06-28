//
//  ImageCropOverlayHeaderView.swift
//  Motesplatsen
//
//  Created by Bogusław Parol on 12/05/2017.
//  Copyright © 2017 Mötesplatsen i Norden AB. All rights reserved.
//

import Foundation
import UIKit

class ImageCropperOverlayHeadView: UIView{
    
    var drawsOval = false
    
    override func draw( _ rect: CGRect){
        
        if drawsOval, let context = UIGraphicsGetCurrentContext(){
            let width: CGFloat = 2
            context.setLineWidth(width)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setFillColor(UIColor.clear.cgColor)
            context.setLineDash(phase: 0, lengths: [10,8])
            
            let path = CGMutablePath()
            var elipseRect = rect
            elipseRect.origin.x += width / 2
            elipseRect.origin.y += width / 2
            elipseRect.size.width -= width
            elipseRect.size.height -= width
            path.addEllipse(in: elipseRect)
            context.addPath(path)
            context.strokePath()
        }
    }
    
}

