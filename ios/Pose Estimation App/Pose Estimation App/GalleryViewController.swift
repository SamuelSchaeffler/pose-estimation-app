//
//  ViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 22.09.23.
//

import UIKit

class GalleryViewController: UIViewController {
    
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        activityIndicator.center = view.center
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}

