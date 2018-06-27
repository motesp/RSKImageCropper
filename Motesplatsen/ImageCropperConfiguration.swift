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
    public var title: String?
    public var subtitle: String?
    public var titleFont: UIFont?
    public var subtitleFont: UIFont?
    public var cancelButtonTitle: String?
    public var approveButtonTitle: String?
    public var buttonsFont: UIFont?
    public var drawsOval: Bool = false
    public var actionBeforeCroping: ((() -> Void) -> Void)?
    public var buttonsPosition: ButtonsPosition = .top
    public var buttonsHorizontalOffset: CGFloat = 30
    public var buttonsVerticalOffset: CGFloat = 30
}
