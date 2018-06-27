//
//  Test.swift
//  RSKImageCropperExample
//
//  Created by Jonny Johansson on 2018-05-11.
//  Copyright © 2018 Ruslan Skorb. All rights reserved.
//

import Foundation
import UIKit
import Vision

@available(iOS 11.0, *)
class FaceDetector: NSObject {

    var completionHandler: (CGRect)->()
    var image: UIImage!
    
    @objc init(image: UIImage, faceDetectedHandler:@escaping (CGRect)->()) {
        self.completionHandler = faceDetectedHandler
        self.image = image

        super.init()
    }
    
    @objc func detectFace() {
        let orientation = CGImagePropertyOrientation(self.image.imageOrientation)
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, orientation: orientation ,options: [:])

        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }

    @objc func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            debugPrint("Face detection failed")
            return
        }
        
        debugPrint("Face detection complete! Found \(observations.count) face(s)")
        
        if let firstFace = observations.first {
            let w = firstFace.boundingBox.size.width * image.size.width
            let h = firstFace.boundingBox.size.height * image.size.height
            let x = firstFace.boundingBox.origin.x * image.size.width
            let y = firstFace.boundingBox.origin.y * image.size.height
            
            let margin: CGFloat = 1.0;
            let firstFaceRect = CGRect(x: x-w*margin, y: image.size.height-y-h-h*margin, width: w+w*margin*2, height: h+h*margin*2)
            
            debugPrint("First face located at \(firstFaceRect.origin.x), \(firstFaceRect.origin.y), \(firstFaceRect.size.width), \(firstFaceRect.size.height)")

            completionHandler(firstFaceRect)
        } else {
            completionHandler(.zero)
        }
    }
    
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImageOrientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}
