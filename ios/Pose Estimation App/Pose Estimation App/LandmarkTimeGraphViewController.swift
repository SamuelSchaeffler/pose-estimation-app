//
//  LandmarkTimeGraphViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 27.10.23.
//

import UIKit
import SwiftUI


class LandmarkTimeGraphViewController: UIViewController {

    var closeButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("zurück", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 5
        let buttonHeight: CGFloat = 30
        button.frame = CGRect(x: 20, y: 20, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 15
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink

        let controller = UIHostingController(rootView: LandmarkChart())
        guard let chartView = controller.view else {
            return
        }
        chartView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.height), height: Int(UIScreen.main.bounds.size.width))
        view.addSubview(chartView)
        
        view.addSubview(closeButton)
    }
    
    @objc func buttonPressed(sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    @objc func buttonReleased(sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    @objc func closeVC() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .portrait
        self.dismiss(animated: true)
    }
}
