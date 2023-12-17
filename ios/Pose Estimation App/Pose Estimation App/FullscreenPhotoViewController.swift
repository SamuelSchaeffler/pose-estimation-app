//
//  FullscreenPhotoViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 05.10.23.
//

import UIKit

class FullscreenPhotoViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage?

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    lazy var fullscreenImageView: UIImageView = {
        let fullscreenImageView = UIImageView()
        fullscreenImageView.image = image
        fullscreenImageView.contentMode = .scaleAspectFit
        fullscreenImageView.clipsToBounds = true
        fullscreenImageView.translatesAutoresizingMaskIntoConstraints = false
        return fullscreenImageView
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeFullscreen), for: .touchUpInside)
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: 15, y: 25, width: buttonWidth, height: buttonHeight)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: Notification.Name("UpdateFullscreenPhoto"), object: nil)

        view.addSubview(scrollView)
        scrollView.addSubview(fullscreenImageView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fullscreenImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            fullscreenImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            fullscreenImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            fullscreenImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc func updateUI(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            fullscreenImageView.image = image
            self.image = image
        }
    }
    
    @objc func closeFullscreen() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .portrait
        self.dismiss(animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        scrollView.setZoomScale(1.0, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullscreenImageView
    }
}
