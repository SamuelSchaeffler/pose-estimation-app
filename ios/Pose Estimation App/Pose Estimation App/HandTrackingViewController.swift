//
//  HandTrackingViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 02.10.23.
//

import UIKit
import MediaPipeTasksVision


class HandTrackingViewController: UIViewController {

    var uiImage: UIImage?
    var mpImage: MPImage?
    var result: HandLandmarkerResult?
    
    var handLandmarker: HandLandmarker?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = uiImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        return imageView
    }()
    
    let handLabel1: UILabel = {
        let label = UILabel()
        label.text = "Anzahl erkannter Hände: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 350, width: width, height: height)
        return label
    }()
    
    let handLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .right
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2) , y: 350, width: width, height: height)
        return label
    }()
    
    let handLabel3: UILabel = {
        let label = UILabel()
        label.text = "Händigkeit: "
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 400, width: width, height: height)
        return label
    }()
    
    let handLabel4: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .right
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: ((UIScreen.main.bounds.size.width - width) / 2), y: 400, width: width, height: height)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhoto(_:)), name: Notification.Name("UpdateTrackingPhoto"), object: nil)

        
        var handLandmarkerOptions: HandLandmarkerOptions
        handLandmarkerOptions = HandLandmarkerOptions()
        handLandmarkerOptions.runningMode = .image
        handLandmarkerOptions.numHands = 2
        handLandmarkerOptions.minHandDetectionConfidence = 0.5
        handLandmarkerOptions.minHandPresenceConfidence = 0.5
        handLandmarkerOptions.minTrackingConfidence = 0.5
        if let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
            handLandmarkerOptions.baseOptions.modelAssetPath = modelPath
        }
        do {
            handLandmarker = try HandLandmarker(options: handLandmarkerOptions)
            print("Tracker initialisiert!")
        } catch {
            print(error)
        }
        
        
        
        view.addSubview(imageView)
        view.addSubview(handLabel1)
        view.addSubview(handLabel2)
        view.addSubview(handLabel3)
        view.addSubview(handLabel4)


    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func updatePhoto(_ notification: Notification) {
        if let image = notification.object as? UIImage {
            mpImage = try! MPImage(uiImage: image)
            uiImage = image
            self.imageView.image = image
            result = try! handLandmarker!.detect(image: mpImage!)
            print("Anzahl erkannter Hände: \(String(describing: result!.handedness.count))")
            handLabel2.text = String(describing: result!.handedness.count)
            
            if result!.handedness.count == 1 {
                let hand = result!.handedness[0]
                handLabel4.text = hand[0].categoryName!
            } else if result!.handedness.count == 2 {
                let hand1 = result!.handedness[0]
                let hand2 = result!.handedness[1]
                handLabel4.text = hand1[0].categoryName! + " & " + hand2[0].categoryName!
            }
            
        }
    }
}
