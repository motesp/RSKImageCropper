//
//  ImageCropperConfiguration.swift
//  RSKImageCropperExample
//
//  Created by Bogusław Parol on 26.06.2018.
//  Copyright © 2018 Ruslan Skorb. All rights reserved.
//

import Foundation
import UIKit

@objc public enum ButtonsPosition: Int {
    case top
    case bottom
}

@objc public class ImageCropperConfiguration: NSObject {
    var title: String?
    var subtitle: String?
    var titleFont: UIFont?
    var subtitleFont: UIFont?
    var cancelButtonTitle: String?
    var approveButtonTitle: String?
    var buttonsFont: UIFont?
    var drawsOval: Bool = false
    var actionBeforeCroping: ((() -> Void) -> Void)?
    var buttonsPosition: ButtonsPosition = .top
    var buttonsHorizontalOffset: CGFloat = 30
    var buttonsVerticalOffset: CGFloat = 30
}
