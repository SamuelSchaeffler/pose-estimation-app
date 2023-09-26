//
//  VideoViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 25.09.23.
//

import UIKit
import AVKit
import CoreData

class VideoViewController: UIViewController {

    var image: UIImage?
    var url: URL?
    var objectID: NSManagedObjectID?
    
    var mediaModel = MediaModel()
    var trashModel = TrashModel()

    lazy var videoViewContainer: UIView = {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        container.backgroundColor = .systemBackground
        return container
    }()

    lazy var videoView: UIImageView = {
        let videoView = UIImageView()
        videoView.image = image
        videoView.contentMode = .scaleAspectFit
        videoView.frame = CGRect(x: 0, y: 0, width: videoViewContainer.frame.width, height: videoViewContainer.frame.height)
        videoView.isUserInteractionEnabled = true
        return videoView
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


    lazy var playButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 80
        button.frame = CGRect(x: (videoViewContainer.frame.width - buttonWidth) / 2, y: (videoViewContainer.frame.height - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: Notification.Name("UpdateVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateURL(_:)), name: Notification.Name("UpdateURL"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateObjectID(_:)), name: Notification.Name("UpdateObjectID"), object: nil)
        
        view.backgroundColor = .systemBackground
        view.addSubview(videoViewContainer)
        videoViewContainer.addSubview(videoView)
        videoViewContainer.addSubview(playButton)
        view.addSubview(deleteButton)
    }

    @objc func updateUI(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            self.videoView.image = image
            print("updated image")
        }
    }

    @objc func updateURL(_ notification: Notification) {
        if let videourl = notification.object as? URL {
            url = videourl
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
    
    @objc func deleteItem() {
        trashModel.moveObjectFromMediaToTrash(objectID: objectID!)
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("SelectedPhotosUpdated"), object: self.mediaModel.getMedia())
    }

    @objc func playVideo() {
        let player = AVPlayer(url: url!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
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
