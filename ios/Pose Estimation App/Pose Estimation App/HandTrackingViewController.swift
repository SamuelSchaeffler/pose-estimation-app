//
//  HandTrackingViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 02.10.23.
//

import UIKit
import CoreData
import MediaPipeTasksVision


class HandTrackingViewController: UIViewController {

    var mediaModel = MediaModel()
    var objectID: NSManagedObjectID?
    var mediaURL: URL?
    var uiImage: UIImage?
    let handLandmarker = MediaPipeHandLandmarker()

    
    var result: HandLandmarkerResult?
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("zurück", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 5
        let buttonHeight: CGFloat = 30
        button.frame = CGRect(x: 20, y: 50, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 15
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
        
        return button
    }()
    
    lazy var photoTitle: UILabel = {
        let title = UILabel()
        title.text = "Foto-Titel"
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .center
        title.frame = CGRect(x: 0, y: 80, width: view.frame.width, height: 40)
        
        return title
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = uiImage
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 120, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        return imageView
    }()
    
    var trackingView: UIImageView = {
        let trackingView = UIImageView()
        trackingView.contentMode = .scaleAspectFit
        trackingView.clipsToBounds = true
        trackingView.frame = CGRect(x: 0, y: 120, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        return trackingView
    }()
    
    let trackingSegmentedControl: UISegmentedControl = {
        let items = ["BoundingBox", "Landmarks"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 250
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y: 465, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    let handLabel1: UILabel = {
        let label = UILabel()
        label.text = "Erkannte Hände: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 510, width: width, height: height)
        return label
    }()
    
    let handLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .right
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2) , y: 510, width: width, height: height)
        return label
    }()
    
    let handLabel3: UILabel = {
        let label = UILabel()
        label.text = "Händigkeit: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 560, width: width, height: height)
        return label
    }()
    
    let handLabel4: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .right
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 560, width: width, height: height)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(updateObjectID(_:)), name: Notification.Name("UpdateObjectID"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhoto(_:)), name: Notification.Name("UpdateTrackingPhoto"), object: nil)
        
        view.addSubview(imageView)
        view.addSubview(trackingView)
        view.addSubview(trackingSegmentedControl)
        view.addSubview(handLabel1)
        view.addSubview(handLabel2)
        view.addSubview(handLabel3)
        view.addSubview(handLabel4)
        view.addSubview(photoTitle)
        view.addSubview(closeButton)
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
    
    @objc func closeVC() {
        trackingSegmentedControl.selectedSegmentIndex = 0
        self.dismiss(animated: true)
    }
    
    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        if selectedIndex == 0 && result!.handedness.count >= 1 {
            trackingView.image = handLandmarker.drawBoundingBoxes()
        } else if selectedIndex == 1 && result!.handedness.count >= 1 {
            trackingView.image = handLandmarker.drawLandmarks()
        }
    }
    
    @objc func updateObjectID(_ notification: Notification) {
        if let id = notification.object as? NSManagedObjectID {
            objectID = id
        }
    }
    
    @objc func updatePhoto(_ notification: Notification) {
        if let url = notification.object as? URL {
            mediaURL = url
            let image = UIImage(contentsOfFile: url.path)
            trackingView.image = nil
            photoTitle.text = String(url.lastPathComponent)
            
            self.imageView.image = image
            result = handLandmarker.detectHands(image: image!)
            
            handLabel2.text = String(describing: result!.handedness.count)
                
            let textLinks = NSMutableAttributedString(string: "Links")
            let textRechts = NSMutableAttributedString(string: "Rechts")
            textLinks.addAttribute(.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, 5))
            textRechts.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, 6))


            if result!.handedness.count == 1 {
                let hand = result!.handedness[0]
                handLabel4.attributedText = (hand[0].categoryName == "Right") ? textRechts : textLinks
                trackingView.image = handLandmarker.drawBoundingBoxes()
            } else if result!.handedness.count == 2 {
                let hand1 = result!.handedness[0]
                let hand2 = result!.handedness[1]
                
                let combinedText = NSMutableAttributedString()
                combinedText.append((hand1[0].categoryName == "Right") ? textRechts : textLinks)
                combinedText.append(NSMutableAttributedString(string: " & "))
                combinedText.append((hand2[0].categoryName == "Right") ? textRechts : textLinks)
                handLabel4.attributedText = combinedText
                
                trackingView.image = handLandmarker.drawBoundingBoxes()
            } else {
                handLabel4.text = ""
            }
                
            
        }
    }
}
