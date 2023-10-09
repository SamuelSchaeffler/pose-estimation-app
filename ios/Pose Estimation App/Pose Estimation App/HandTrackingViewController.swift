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
    var mpImage: MPImage?
    
    var result: HandLandmarkerResult?
    var handLandmarkerOptions: HandLandmarkerOptions = {
        let options = HandLandmarkerOptions()
        options.runningMode = .image
        options.numHands = 2
        options.minHandDetectionConfidence = 0.5
        options.minHandPresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5
        if let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
            options.baseOptions.modelAssetPath = modelPath
        }
        return options
    }()
    var handLandmarker: HandLandmarker?
    
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

        do {
            handLandmarker = try HandLandmarker(options: handLandmarkerOptions)
            print("Tracker initialisiert!")
        } catch {
            print(error)
        }
        
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
            drawBoundingBox()
        } else if selectedIndex == 1 && result!.handedness.count >= 1 {
            drawLandmarks()
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
            
            uiImage = image
            mpImage = try! MPImage(uiImage: image!)
            self.imageView.image = image
            result = try! handLandmarker!.detect(image: mpImage!)
            handLabel2.text = String(describing: result!.handedness.count)
                
            let textLinks = NSMutableAttributedString(string: "Links")
            let textRechts = NSMutableAttributedString(string: "Rechts")
            textLinks.addAttribute(.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, 5))
            textRechts.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, 6))


            if result!.handedness.count == 1 {
                let hand = result!.handedness[0]
                handLabel4.attributedText = (hand[0].categoryName == "Right") ? textRechts : textLinks
                drawBoundingBox()
            } else if result!.handedness.count == 2 {
                let hand1 = result!.handedness[0]
                let hand2 = result!.handedness[1]
                
                let combinedText = NSMutableAttributedString()
                combinedText.append((hand1[0].categoryName == "Right") ? textRechts : textLinks)
                combinedText.append(NSMutableAttributedString(string: " & "))
                combinedText.append((hand2[0].categoryName == "Right") ? textRechts : textLinks)
                handLabel4.attributedText = combinedText
                
                drawBoundingBox()
            } else {
                handLabel4.text = ""
            }
                
            
        }
    }
        
    func drawBoundingBox() {
        var index = -1
        let image = imageView.image!
        let imageSize = image.size
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        for hand in result!.landmarks {
            index = index + 1
            let coordinates = hand

            let rectColor: UIColor
            if  result!.handedness[index][0].categoryName! == "Right" {
                rectColor = UIColor.red
            } else {
                rectColor = UIColor.blue
            }
            var minX = CGFloat.greatestFiniteMagnitude
            var maxX = -CGFloat.greatestFiniteMagnitude
            var minY = CGFloat.greatestFiniteMagnitude
            var maxY = -CGFloat.greatestFiniteMagnitude

            if imageSize.height > imageSize.width {
                for coordinate in coordinates {
                    minX = min(minX, CGFloat(coordinate.y))
                    maxX = max(maxX, CGFloat(coordinate.y))
                    minY = min(minY, CGFloat(coordinate.x))
                    maxY = max(maxY, CGFloat(coordinate.x))
                }
                minX = imageSize.width - (minX * imageSize.width)
                maxX = imageSize.width - (maxX * imageSize.width)
                minY = minY * imageSize.height
                maxY = maxY * imageSize.height
            } else {
                for coordinate in coordinates {
                    minX = min(minX, CGFloat(coordinate.x))
                    maxX = max(maxX, CGFloat(coordinate.x))
                    minY = min(minY, CGFloat(coordinate.y))
                    maxY = max(maxY, CGFloat(coordinate.y))
                }
                minX = minX * imageSize.width
                maxX = maxX * imageSize.width
                minY = minY * imageSize.height
                maxY = maxY * imageSize.height
            }
            
            let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            let path = UIBezierPath(rect: rect)
            rectColor.setStroke()
            path.lineWidth = imageSize.width / 95
            path.stroke()
        }
        
        
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            trackingView.image = newImage
        } else {
            UIGraphicsEndImageContext()
        }
    }
    
    func drawLandmarks() {
        var index = -1
        let image = imageView.image!
        let imageSize = image.size
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        for hand in result!.landmarks {
            index = index + 1
            let coordinates = hand
            
            let lineColor = UIColor.gray
            let path = UIBezierPath()
            path.lineWidth = imageSize.width / 90
            lineColor.setStroke()
            
            var points: [CGPoint] = []
            if imageSize.height > imageSize.width {
                for i in 0..<21 {
                    points.append(CGPoint(x: imageSize.width - (Double((coordinates[i].y)) * imageSize.width), y: Double(coordinates[i].x) * imageSize.height))
                }
            } else {
                for i in 0..<21 {
                    points.append(CGPoint(x: Double((coordinates[i].x)) * imageSize.width, y: Double(coordinates[i].y) * imageSize.height))
                }
            }
            
            path.move(to: points[0])
            path.addLine(to: points[1])
            path.addLine(to: points[2])
            path.addLine(to: points[3])
            path.addLine(to: points[4])
            
            path.move(to: points[0])
            path.addLine(to: points[5])
            path.addLine(to: points[6])
            path.addLine(to: points[7])
            path.addLine(to: points[8])
            
            path.move(to: points[0])
            path.addLine(to: points[9])
            path.addLine(to: points[10])
            path.addLine(to: points[11])
            path.addLine(to: points[12])
            
            path.move(to: points[0])
            path.addLine(to: points[13])
            path.addLine(to: points[14])
            path.addLine(to: points[15])
            path.addLine(to: points[16])
            
            path.move(to: points[0])
            path.addLine(to: points[17])
            path.addLine(to: points[18])
            path.addLine(to: points[19])
            path.addLine(to: points[20])
            
            path.stroke()
            
            let pointColor: UIColor
            if  result!.handedness[index][0].categoryName! == "Right" {
                pointColor = UIColor.red
            } else {
                pointColor = UIColor.blue
            }
            let pointRadius: CGFloat = imageSize.width / 50
            
            if imageSize.height > imageSize.width {
                for point in coordinates {
                    let x = imageSize.width - (CGFloat(point.y) * imageSize.width)
                    let y = CGFloat(point.x) * imageSize.height
                    let pointRect = CGRect(x: x - pointRadius / 2.0, y: y - pointRadius / 2.0, width: pointRadius, height: pointRadius)
                    let path = UIBezierPath(ovalIn: pointRect)
                    pointColor.setFill()
                    path.fill()
                }
            } else {
                for point in coordinates {
                    let x = CGFloat(point.x) * imageSize.width
                    let y = CGFloat(point.y) * imageSize.height
                    let pointRect = CGRect(x: x - pointRadius / 2.0, y: y - pointRadius / 2.0, width: pointRadius, height: pointRadius)
                    let path = UIBezierPath(ovalIn: pointRect)
                    pointColor.setFill()
                    path.fill()
                }
            }
        }
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            trackingView.image = newImage
        } else {
            UIGraphicsEndImageContext()
        }
    }
}
