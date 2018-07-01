//
//  MPExampleViewController.swift
//  RSKImageCropperExample
//
//  Created by Bogusław Parol on 26.06.2018.
//  Copyright © 2018 Ruslan Skorb. All rights reserved.
//

import Foundation
import UIKit

class MPExampleViewController: UIViewController {
    
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView = UIImageView()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.backgroundColor = UIColor.red
        self.imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
        ])
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.setTitle("Cropp", for: .normal)
        button.backgroundColor = UIColor.green
        button.addTarget(self, action: #selector(showCropper), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50),
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
        ])
    }
    
    @objc private func showCropper() {
        let vc = ImageCropperViewController(image: UIImage(named: "photo")!, cropMode: .custom)
        vc.cropperDelegate = self
        vc.setup(configuration: configurationForGoodones())
        //vc.setup(configuration: configurationForMp())
        self.present(vc, animated: true)
    }
    
    private func configurationForGoodones() -> ImageCropperConfiguration {
        let configuration = ImageCropperConfiguration()
        configuration.title = "Flytta och skala"
        configuration.titleFont = UIFont.preferredFont(forTextStyle: .title1)
        configuration.subtitleFont = UIFont.preferredFont(forTextStyle: .body)
        configuration.cancelButtonTitle = "Cancel"
        configuration.approveButtonTitle = "Approve"
        configuration.buttonsFont = UIFont.preferredFont(forTextStyle: .title3)
        configuration.buttonsPosition = .bottom
        configuration.tutorialHidden = false
        configuration.drawsOval = false
        configuration.rectangleWidthToHeightRatio = 315/408
        return configuration
    }
    
    private func configurationForMp() -> ImageCropperConfiguration {
        let configuration = ImageCropperConfiguration()
        configuration.title = "Passa in ditt ansikte i cirkeln"
        configuration.titleFont = UIFont.preferredFont(forTextStyle: .title2)
        configuration.titleTop = 59
        configuration.subtitle = "Nyp med två fingrar för att zooma.\nDra i bilden med ett finger för att flytta."
        configuration.subtitleFont = UIFont.preferredFont(forTextStyle: .subheadline)
        configuration.cancelButtonTitle = "Avbryt"
        configuration.approveButtonTitle = "Spara"
        configuration.buttonsFont = UIFont.preferredFont(forTextStyle: .body)
        configuration.buttonsHorizontalOffset = 8
        configuration.buttonsVerticalOffset = 10
        configuration.rectangleWidthToHeightRatio = 255.0/339.0
        configuration.rectangleHorizontalOffset = 33.0
        configuration.drawsOval = true
        return configuration
    }
}

extension MPExampleViewController: ImageCropperViewControllerDelegate {
    
    func didComplete(image: UIImage) {
        self.imageView.image = image
    }
}


