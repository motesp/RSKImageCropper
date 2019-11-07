//
//  ImageEditorViewController.swift
//  Motesplatsen
//
//  Created by Bogusław Parol on 11/05/2017.
//  Copyright © 2017 Mötesplatsen i Norden AB. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCropperOverlayDelegate: class {
    
}

class ImageCropperOverlayViewController: UIViewController {
    
    @IBOutlet weak var blurView: UIView!
    
    @IBOutlet weak var rectangleView: UIView!
    @IBOutlet weak var headView: ImageCropperOverlayHeadView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var tutorialStackView: UIStackView!
    @IBOutlet weak var tutorialContainer: UIView!
    @IBOutlet weak var tutorialBackground: UIView!
    @IBOutlet weak var rectangleLeading: NSLayoutConstraint!
    @IBOutlet weak var rectangleTrailing: NSLayoutConstraint!
    
    func setup(configuration: ImageCropperConfiguration){

        var viewAboveRectangle: UIView?
        
        let marginsGuide = view.layoutMarginsGuide
        
        if configuration.title != nil {
            topLabel.topAnchor.constraint(equalTo: marginsGuide.topAnchor, constant: configuration.titleTop).isActive = true
            viewAboveRectangle = topLabel
        }
        
        if configuration.subtitle != nil {
            bottomLabel.topAnchor.constraint(equalTo: topLabel.firstBaselineAnchor, constant: 10).isActive = true
            viewAboveRectangle = bottomLabel
        }
        
        if let viewAboveRectangle = viewAboveRectangle {
            rectangleView.topAnchor.constraint(equalTo: viewAboveRectangle.bottomAnchor, constant: 20).isActive = true
        } else {
            rectangleView.topAnchor.constraint(equalTo: marginsGuide.topAnchor, constant: 10).isActive = true
        }
        
        self.rectangleLeading.constant = configuration.rectangleHorizontalOffset
        self.rectangleTrailing.constant = configuration.rectangleHorizontalOffset
        self.rectangleView.widthAnchor.constraint(
            equalTo: self.rectangleView.heightAnchor,
            multiplier: configuration.rectangleWidthToHeightRatio).isActive = true
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.view.backgroundColor = UIColor.clear
        self.rectangleView.backgroundColor = UIColor.clear
        self.rectangleView.layer.borderColor = UIColor.white.cgColor
        self.rectangleView.layer.borderWidth = 1
        self.headView.backgroundColor = UIColor.clear
        self.headView.layer.masksToBounds = false
        self.headView.drawsOval = configuration.drawsOval
        self.view.backgroundColor = UIColor.clear
        
        self.topLabel.text = configuration.title
        self.topLabel.font = configuration.titleFont        
        self.bottomLabel.text = configuration.subtitle
        self.bottomLabel.font = configuration.subtitleFont
        self.bottomLabel.alpha = 0.6
        
        self.tutorialBackground.alpha = 0.7
        self.tutorialBackground.layer.cornerRadius = 8
        self.tutorialContainer.isHidden = configuration.tutorialHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let blurSubviews = self.blurView.subviews
        for index in 0..<blurSubviews.count {
            blurSubviews[index].removeFromSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .light)
        let visualView = UIVisualEffectView(effect: blurEffect)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        
        self.blurView.addSubview(visualView)
        NSLayoutConstraint.activate([
            visualView.leftAnchor.constraint(equalTo: self.blurView.leftAnchor),
            visualView.topAnchor.constraint(equalTo: self.blurView.topAnchor),
            visualView.rightAnchor.constraint(equalTo: self.blurView.rightAnchor),
            visualView.bottomAnchor.constraint(equalTo: self.blurView.bottomAnchor)
        ])
        let maskView = UIView(frame: blurView.bounds)
        maskView.clipsToBounds = true
        maskView.backgroundColor = UIColor.clear
        
        let outerbezierPath = UIBezierPath.init(roundedRect: blurView.bounds, cornerRadius: 0)
        let rect = self.rectangleView.frame
        let innerCirclepath = UIBezierPath.init(roundedRect: rect, cornerRadius: 0)
        outerbezierPath.append(innerCirclepath)
        outerbezierPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.black.cgColor // any opaque color would work
        fillLayer.path = outerbezierPath.cgPath
        maskView.layer.addSublayer(fillLayer)
        
        visualView.mask = maskView
    }
    
    func animateHidingTutorial() {
        UIView.animate(withDuration: 1) {
            self.tutorialContainer.alpha = 0
        }
    }
}
