//
//  PhotoViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 25.09.23.
//

import UIKit
import CoreData

class PhotoViewController: UIViewController {
    
    var image: UIImage?
    var objectID: NSManagedObjectID?
    
    var mediaModel = MediaModel()
    var trashModel = TrashModel()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        //imageView.backgroundColor = .red
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullscreenImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
        
    lazy var fullscreenImageView: UIImageView = {
        let fullscreenImageView = UIImageView()
        fullscreenImageView.image = imageView.image
        fullscreenImageView.frame = view.bounds
        fullscreenImageView.backgroundColor = .systemBackground
        fullscreenImageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeFullscreenImage))
        fullscreenImageView.isUserInteractionEnabled = true
        fullscreenImageView.addGestureRecognizer(tapGesture)
        return fullscreenImageView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let image = UIImage(systemName: "trash", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.setTitle("löschen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let spacing: CGFloat = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 3
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: ((UIScreen.main.bounds.size.width) / 2) + 35, y: UIScreen.main.bounds.size.height - 150, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 25
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: Notification.Name("UpdatePhoto"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateObjectID(_:)), name: Notification.Name("UpdateObjectID"), object: nil)
        
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(deleteButton)
    }
    
    @objc func updateUI(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            self.imageView.image = image
        }
    }
    
    @objc func updateObjectID(_ notification: Notification) {
        if let id = notification.object as? NSManagedObjectID {
            objectID = id
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func showFullscreenImage() {
        view.addSubview(fullscreenImageView)
        fullscreenImageView.image = imageView.image
    }
    
    @objc private func closeFullscreenImage() {
        fullscreenImageView.removeFromSuperview()
    }
    
    @objc func deleteItem() {
        trashModel.moveObjectFromMediaToTrash(objectID: objectID!)
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
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
}
