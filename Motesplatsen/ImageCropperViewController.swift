//
//  ImageCropperViewController.swift
//  Motesplatsen
//
//  Created by Bogusław Parol on 12/05/2017.
//  Copyright © 2017 Mötesplatsen i Norden AB. All rights reserved.
//

import Foundation
import UIKit

public protocol ImageCropperViewControllerDelegate: class{
    func didComplete(image: UIImage)
}

public class ImageCropperViewController: RSKImageCropViewController{
    
    public weak var cropperDelegate: ImageCropperViewControllerDelegate?
    public var zoomRect: CGRect = .zero
    public var onCroppingCompleted: ((UIImage) -> Void)?
    
    private weak var customCancelButton: UIButton!
    private weak var customChooseButton: UIButton!    
    private weak var overlayViewController: ImageCropperOverlayViewController?
    private  var configuration: ImageCropperConfiguration?
    private var panRecognizer: UIGestureRecognizer?
    private var pinchRecognizer: UIGestureRecognizer?
    
    @objc public func setup(configuration: ImageCropperConfiguration){
        self.configuration = configuration
        
        self.applyMaskToCroppedImage = true
        self.avoidEmptySpaceAroundImage = true
        self.alwaysBounceVertical = true
        self.alwaysBounceHorizontal = true
        
        // overlay
        let bundle = Bundle(for: ImageCropperOverlayViewController.self)
        let overlayViewController = ImageCropperOverlayViewController(nibName: "ImageCropperOverlay", bundle: bundle)
        self.addChildViewController(overlayViewController)
        if let overlayView = overlayViewController.view {
            self.view.addSubview(overlayView)            
            NSLayoutConstraint.activate([
                overlayView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                overlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
                overlayView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
        overlayViewController.setup(configuration: configuration)
        self.overlayViewController = overlayViewController
        
        let maxButtonHeight: CGFloat = 35
        
        // cancel button
        let cancelBtn = UIButton()
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.addTarget(self, action: #selector(customCancelButtonPressed), for: .touchUpInside)
        cancelBtn.setTitle(configuration.cancelButtonTitle, for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.titleLabel?.font = configuration.buttonsFont
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelBtn.titleLabel?.minimumScaleFactor = 0.5
        cancelBtn.contentHorizontalAlignment = .left
        cancelBtn.titleLabel?.sizeToFit()
        self.view.addSubview(cancelBtn)
        NSLayoutConstraint.activate([
            cancelBtn.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: configuration.buttonsHorizontalOffset),
            cancelBtn.rightAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor, constant: -10),
            cancelBtn.heightAnchor.constraint(lessThanOrEqualToConstant: maxButtonHeight),
            cancelBtn.titleLabel!.heightAnchor.constraint(lessThanOrEqualToConstant: maxButtonHeight)
        ])
        self.customCancelButton = cancelBtn
        
        // approve button
        let chooseBtn = UIButton()
        chooseBtn.translatesAutoresizingMaskIntoConstraints = false
        chooseBtn.addTarget(self, action: #selector(customChooseButtonPressed), for: .touchUpInside)
        chooseBtn.setTitle(configuration.approveButtonTitle, for: .normal)
        chooseBtn.setTitleColor(UIColor.white, for: .normal)
        chooseBtn.titleLabel?.font = configuration.buttonsFont
        chooseBtn.contentHorizontalAlignment = .right
        chooseBtn.titleLabel?.numberOfLines = 0
        chooseBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        chooseBtn.titleLabel?.minimumScaleFactor = 0.5
        self.view.addSubview(chooseBtn)
        NSLayoutConstraint.activate([
            chooseBtn.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -configuration.buttonsHorizontalOffset),
            chooseBtn.leftAnchor.constraint(greaterThanOrEqualTo: self.view.centerXAnchor, constant: 10),
            chooseBtn.topAnchor.constraint(equalTo: cancelBtn.topAnchor),
            chooseBtn.heightAnchor.constraint(lessThanOrEqualToConstant: maxButtonHeight),
            chooseBtn.titleLabel!.heightAnchor.constraint(lessThanOrEqualToConstant: maxButtonHeight)
        ])
        self.customChooseButton = chooseBtn
        
        // layout buttons according to position
        if configuration.buttonsPosition == .top {
            NSLayoutConstraint.activate([
                cancelBtn.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: configuration.buttonsVerticalOffset),
                chooseBtn.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: configuration.buttonsVerticalOffset)
            ])
        }else{
            NSLayoutConstraint.activate([
                cancelBtn.bottomAnchor.constraint(greaterThanOrEqualTo: self.view.bottomAnchor, constant: -configuration.buttonsVerticalOffset),
                chooseBtn.bottomAnchor.constraint(greaterThanOrEqualTo: self.view.bottomAnchor,constant: -configuration.buttonsVerticalOffset),
            ])
        }
 
        if !configuration.tutorialHidden {
            addGestureRecognizersForHidingTutorial()
        }
    }
    
    @objc private func customCancelButtonPressed(){
        self.cancelCrop()
    }
    
    @objc private func customChooseButtonPressed(){
        if self.configuration?.actionBeforeCroping != nil {
            self.configuration?.actionBeforeCroping?({ [weak self] in
                self?.cropImage()
            })
        }else {
            self.cropImage()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.clearControlsThatWeDontWantTo()
    }
    
    
    private func addGestureRecognizersForHidingTutorial(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onTouch))
        pan.delegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onTouch))
        pinch.delegate = self
        self.view.addGestureRecognizer(pan)
        self.view.addGestureRecognizer(pinch)
    }
    
    @objc private func onTouch() {
    
    }
    
    private func removeGestureRecognizersForHidingTutorial(){
        if let panGR = panRecognizer {
            self.view.removeGestureRecognizer(panGR)
            self.panRecognizer = nil
        }
        if let pinchGR = pinchRecognizer {
            self.view.removeGestureRecognizer(pinchGR)
            self.pinchRecognizer = nil
        }
    }
    
    private func clearControlsThatWeDontWantTo(){
        self.moveAndScaleLabel.text = ""
        self.cancelButton.isUserInteractionEnabled = false
        self.cancelButton.setTitle("", for: .normal)
        self.chooseButton.isUserInteractionEnabled = false
        self.chooseButton.setTitle("", for: .normal)
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
}

extension ImageCropperViewController: RSKImageCropViewControllerDelegate{
    
    public func imageCropViewControllerDidDisplayImage(_ controller: RSKImageCropViewController) {
        if zoomRect != .zero {
            let offset: CGFloat = 0.25 // Move head up 25% of the height, since we don't have square photos, but rectangular
            
            let offsetHeight = zoomRect.height * offset
            let offsetY = zoomRect.origin.y - offsetHeight > 0 ? offsetHeight : 0
            let offsetRect = zoomRect.offsetBy(dx: 0, dy: offsetY)
            
            debugPrint("Zooming to \(zoomRect.origin.x), \(zoomRect.origin.y), \(zoomRect.size.width), \(zoomRect.size.height)")
            self.zoom(to: offsetRect, animated: true)
        }
    }
    
    public func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController){
        controller.dismiss(animated: true) {}
    }
    
    public func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat){

        debugPrint("Original image: \(self.originalImage.size), cropped image: \(croppedImage.size), rect: \(cropRect)")
        
        var bounds = CGRect.zero
        bounds.size = cropRect.size
        bounds = bounds.insetBy(dx: 1, dy: 1)
        
        if let correctedCGImage = croppedImage.cgImage?.cropping(to: bounds){
            let correctedImage = UIImage(cgImage: correctedCGImage)
            self.onCroppingCompleted?(correctedImage)
            self.cropperDelegate?.didComplete(image: correctedImage)
        }
        controller.dismiss(animated: true) {}
    }
}

extension ImageCropperViewController: RSKImageCropViewControllerDataSource{
    
    public func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        if let frame = self.overlayViewController?.rectangleView.frame{
            return frame.insetBy(dx: 1, dy: 1).integral
        }
        return CGRect.zero
    }
    
    public func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {

        let rect = controller.maskRect
        let point1 = CGPoint(x: rect.minX,y: rect.maxY)
        let point2 = CGPoint(x: rect.maxX,y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX,y: rect.minY)
        let point4 = CGPoint(x: rect.minX,y: rect.minY)

        
        let triangle = UIBezierPath()
        triangle.move(to: point1)
        triangle.addLine(to: point2)
        triangle.addLine(to: point3)
        triangle.addLine(to: point4)
        triangle.close()
        
        return triangle
    }
    
    public func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}

extension ImageCropperViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: self.view)
        if let rectangeView = self.overlayViewController?.rectangleView {
            let insideRectangle = rectangeView.frame.contains(location)
            if insideRectangle {
                self.overlayViewController?.animateHidingTutorial()
                self.removeGestureRecognizersForHidingTutorial()
            }
            return insideRectangle
        }
        return false
    }
}
