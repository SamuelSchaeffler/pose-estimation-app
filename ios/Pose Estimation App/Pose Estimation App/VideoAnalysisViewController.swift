//
//  VideoAnalysisViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 27.10.23.
//

import UIKit
import AVKit
import CoreData
import SceneKit


class VideoAnalysisViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var image: UIImage?
    var url: URL?
    var videoTitleString: String?
    var outputURL: URL?
    var objectID: NSManagedObjectID?
    var mediaModel = MediaModel()
    
    var videoLandmarks: [[SCNVector3]] = [[]]
    var videoTimestamps: [Int] = []
    
    let pickerData = ["WRIST", "THUMB_CMC", "THUMB_MCP", "THUMB_IP", "THUMB_TIP", "INDEX_MCP", "INDEX_PIP", "INDEX_DIP", "INDEX_TIP", "MIDDLE_MCP", "MIDDLE_PIP", "MIDDLE_DIP", "MIDDLE_TIP", "RING_MCP", "RING_PIP", "RING_DIP", "RING_TIP", "PINKY_MCP", "PINKY_PIP", "PINKY_DIP", "PINKY_TIP"]
    
    var videoAnalysisSettings: [Int] = [0,0,0]
    
    let handLandmarker = MediaPipeHandLandmarkerVideo()
    
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
    
    lazy var videoViewContainer: UIView = {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 2.5)
        container.backgroundColor = .systemBackground
        return container
    }()

    lazy var videoView: UIImageView = {
        let videoView = UIImageView()
        videoView.image = image
        videoView.contentMode = .scaleAspectFill
        videoView.clipsToBounds = true
        videoView.frame = CGRect(x: 0, y: 0, width: videoViewContainer.frame.width, height: videoViewContainer.frame.height)
        videoView.isUserInteractionEnabled = true
        return videoView
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

    lazy var videoTitle: UILabel = {
        let title = UILabel()
        title.text = videoTitleString
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .center
        title.frame = CGRect(x: 0, y: (UIScreen.main.bounds.size.height / 2.5) + 10, width: view.frame.width, height: 40)
        
        return title
    }()
    
    let handLabel: UILabel = {
        let label = UILabel()
        label.text = "Hand"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 400, width: width, height: height)
        return label
    }()
    
    let handSegmentedControl: UISegmentedControl = {
        let items = ["Links", "Rechts"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 200
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) - 50, y: 400, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    let axisLabel: UILabel = {
        let label = UILabel()
        label.text = "Achse"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 450, width: width, height: height)
        return label
    }()
    
    let axisSegmentedControl: UISegmentedControl = {
        let items = ["X", "Y", "Z"]
        let segmentedControl = UISegmentedControl(items: items)
        let width: CGFloat = 200
        let height: CGFloat = 30
        segmentedControl.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) - 50, y: 450, width: width, height: height)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()
   
    let landmarkLabel: UILabel = {
        let label = UILabel()
        label.text = "Landmarke"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
        let width: CGFloat = 250
        let height: CGFloat = 30
        label.frame = CGRect(x: 50, y: 500, width: width, height: height)
        return label
    }()
    
    let pickerView: UIPickerView = {
        let picker = UIPickerView()
        let width: CGFloat = 200
        let height: CGFloat = 50
        picker.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) - 40, y: 490, width: width, height: height)
        return picker
    }()
    
    var coordinateSystemImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "CoordinateSystemX")
        view.contentMode = .scaleAspectFit
        let width: CGFloat = 220
        let height: CGFloat = 220
        view.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y: UIScreen.main.bounds.size.height - 300, width: width, height: height)
        return view
    }()
    
    lazy var graphButton: UIButton = {
        let button = UIButton()
        button.adjustsImageWhenHighlighted = false
        button.setTitle("Bewegungsanalyse", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openGraph), for: .touchUpInside)
        let buttonWidth: CGFloat = UIScreen.main.bounds.size.width / 2
        let buttonHeight: CGFloat = 50
        button.frame = CGRect(x: (UIScreen.main.bounds.size.width - buttonWidth) / 2, y: UIScreen.main.bounds.size.height - 100, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = 25
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
            
        
        return button
    }()
    
    var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Handerkennung wird ausgeführt", message: "Bitte warten...", preferredStyle: .alert)
        
        var progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.setProgress(0.0, animated: true)
        progressBar.frame = CGRect(x: 10, y: 90, width: 250, height: 3)
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            NotificationCenter.default.post(name: Notification.Name("cancelAlert"), object: nil)
        }
        //alertController.addAction(cancelAction)
        alertController.view.addSubview(progressBar)

        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(closeAlert(_:)), name: Notification.Name("closeAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelAlert(_:)), name: Notification.Name("cancelAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)), name: Notification.Name("updateProgress"), object: nil)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        view.addSubview(videoViewContainer)
        videoViewContainer.addSubview(videoView)
        videoViewContainer.addSubview(playButton)
        view.addSubview(videoTitle)
        view.addSubview(handLabel)
        view.addSubview(handSegmentedControl)
        view.addSubview(axisLabel)
        view.addSubview(axisSegmentedControl)
        view.addSubview(landmarkLabel)
        view.addSubview(pickerView)
        view.addSubview(closeButton)
        view.addSubview(coordinateSystemImage)
        view.addSubview(graphButton)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if mediaModel.checkVideoLandmarks(objectID: objectID!) == false {
            present(alertController, animated: false)
            //main = 27sec / background = 59sec / main + uipdate = 27sec / main + no debugmode = 20sec
            DispatchQueue.main.async { [self] in
                handLandmarker.generateVideoWithLandmarks(objectID: objectID!)
            }
        } else {
            let string = mediaModel.getVideoLandmarks(objectID: objectID!)
            let data = stringToVideoLandmarks(string)!
            videoLandmarks = data.0
            videoTimestamps = data.1
        }
    }
    
    @objc func updateProgress(_ notification: Notification) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.001))
        let progress = notification.object as! Float
        if let progressBar = self.alertController.view.subviews.first(where: { $0 is UIProgressView }) as? UIProgressView {
            progressBar.setProgress(progress, animated: true)
        }
    }
    @objc func closeAlert(_ notification: Notification) {
        DispatchQueue.main.async { [self] in
            alertController.dismiss(animated: true)
        }
        let data = notification.object as! ([[SCNVector3]], [Int])
        videoLandmarks = data.0
        videoTimestamps = data.1
    }
    @objc func cancelAlert(_ notification: Notification) {
        DispatchQueue.main.async { [self] in
            self.dismiss(animated: true)
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
    @objc func closeVC() {
        self.dismiss(animated: true)
    }
    @objc func playVideo() {
        let player = AVPlayer(url: annotatedURL(from: url!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    @objc func segmentedControlValueChanged(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let selectedOption = sender.titleForSegment(at: selectedIndex)
        
        if sender == handSegmentedControl {
            videoAnalysisSettings[0] = sender.selectedSegmentIndex
        } else {
            videoAnalysisSettings[1] = sender.selectedSegmentIndex
            if sender.selectedSegmentIndex == 0 {
                coordinateSystemImage.image = UIImage(named: "CoordinateSystemX")
            } else if sender.selectedSegmentIndex == 1 {
                coordinateSystemImage.image = UIImage(named: "CoordinateSystemY")
            } else {
                coordinateSystemImage.image = UIImage(named: "CoordinateSystemZ")
            }
        }
    }
    
    @objc func openGraph() {
        let landmarkPoint = videoAnalysisSettings[2]
        var coordinates: [Float] = []
        if videoAnalysisSettings[1] == 0 {
            //x
            for subArray in videoLandmarks {
                let point = subArray[landmarkPoint]
                coordinates.append(point.x)
            }
        } else if videoAnalysisSettings[1] == 1 {
            //y
            for subArray in videoLandmarks {
                let point = subArray[landmarkPoint]
                coordinates.append(point.y)
            }
        } else {
            //z
            for subArray in videoLandmarks {
                let point = subArray[landmarkPoint]
                coordinates.append(point.z)
            }
        }
        chartDataArrays = (coordinates, videoTimestamps)
        dataList = []
        var index = 0
        for point in chartDataArrays.0 {
            dataList.append(chartData(landmark: point, timestamp: chartDataArrays.1[index]))
            index = index + 1
        }
        
        let graphVC = LandmarkTimeGraphViewController()
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.orientationLock = .landscapeLeft
            
            graphVC.modalPresentationStyle = .fullScreen
            self.present(graphVC, animated: true, completion: nil)
            
        }
    }
    
    // MARK: - UIPickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected Option: \(pickerData[row])")
        videoAnalysisSettings[2] = row
    }
}
