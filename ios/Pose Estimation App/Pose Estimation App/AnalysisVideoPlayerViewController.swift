//
//  AnalysisVideoPlayerViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 04.11.23.
//

import UIKit
import SwiftUI
import AVFoundation
import SceneKit

class AnalysisVideoPlayerViewController: UIViewController {

    var player: AVPlayer!
    var duration: Float64?
    var currentTimeMillis: Int = 0
    var currentLandmarkIndex: Int = 0
    var naturalSize: CGSize!
    var videoWidth: Int?
    var videoHeight: Int?
    var videoIsPortrait: Bool?
    var hideButtonTimer: Timer?
    var timeObserverToken: Any?
    var buttonStates: [Bool] = [false, false, true, false, false, false]
    var landmarksView: LandmarksView!
    var landmarkFrame: CGRect?
    var videoTimestamps: [Int]!
    var videoLandmarks: [[CGPoint]]!
    var videoLandmarks3: [[SCNVector3]] = []
    var landmarks: [Landmark] = []
    var landmarkMemory: [Landmark] = []
    var firstFrame: Bool = true
    var videoAngle: CGFloat = 0
    var anglesGenerated: Bool = false
    var videoURL: URL?
    
    let playerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        return view
    }()
    
    var chartView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        return view
    }()
    
    let chart: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        view.isHidden = true
        return view
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - buttonWidth) / 2, y: (UIScreen.main.bounds.size.width - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        button.frame = CGRect(x: 10, y: 10, width: buttonWidth, height: buttonHeight)
        return button
    }()
    
    var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    
    let slider: UISlider = {
        let frame = CGRect(x: 40, y: UIScreen.main.bounds.size.width - 60, width: UIScreen.main.bounds.size.height - 80, height: 24)
        let slider = CustomSlider(frame: frame)
        slider.customTrackHeight = 13
        let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "maxTrackImage"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "minTrackImage"), for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    let currentLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 45, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    let remainingLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: UIScreen.main.bounds.size.height - 95, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    let selectLandmarksButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openLanmarkSelection), for: .touchUpInside)
        let buttonWidth: CGFloat = 45
        let buttonHeight: CGFloat = 40
        button.frame = CGRect(x: (40), y: (UIScreen.main.bounds.size.width - 95), width: buttonWidth, height: buttonHeight)
        return button
    }()
    
    let openChartButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
        let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openChart), for: .touchUpInside)
        let buttonWidth: CGFloat = 38
        let buttonHeight: CGFloat = 38
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 78), y: (UIScreen.main.bounds.size.width - 95), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let selectAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
        let image = UIImage(systemName: "x.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(selectAxis), for: .touchUpInside)
        let buttonWidth: CGFloat = 38
        let buttonHeight: CGFloat = 38
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 78), y: (UIScreen.main.bounds.size.width - 145), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let zAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold)
        let image = UIImage(systemName: "z.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(zAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 32
        let buttonHeight: CGFloat = 32
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 75), y: (UIScreen.main.bounds.size.width - 185), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let yAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold)
        let image = UIImage(systemName: "y.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(yAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 32
        let buttonHeight: CGFloat = 32
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 108), y: (UIScreen.main.bounds.size.width - 175), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let xAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold)
        let image = UIImage(systemName: "x.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemGreen.withAlphaComponent(0.8), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(xAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 32
        let buttonHeight: CGFloat = 32
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 118), y: (UIScreen.main.bounds.size.width - 142), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let openAngleChartButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
        let image = UIImage(named: "angle.button")
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openAngleChart), for: .touchUpInside)
        let buttonWidth: CGFloat = 33
        let buttonHeight: CGFloat = 33
        button.frame = CGRect(x: (40), y: (UIScreen.main.bounds.size.width - 95), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    
    let chartOpacitySlider: UISlider = {
        let frame = CGRect(x: (UIScreen.main.bounds.size.height - 135), y: (UIScreen.main.bounds.size.width - 275), width: 150, height: 10)
        let slider = CustomSlider(frame: frame)
        slider.customTrackHeight = 13
        let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "maxTrackImage0.1"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "minTrackImage0.1"), for: .normal)
        slider.isHidden = true
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 80
        slider.addTarget(self, action: #selector(opacitySliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black

        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        playerView.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        view.addSubview(playerView)
  
        setScreenOrientation()
             
        landmarksView = LandmarksView(frame: landmarkFrame!)
        landmarksView.backgroundColor = .clear
        landmarksView.isUserInteractionEnabled = true
        view.addSubview(landmarksView)
        
        let landmarkInterval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: landmarkInterval, queue: DispatchQueue.main) { [weak self] time in
            self?.updateLandmarks(for: time)
        }
        
        view.addSubview(chart)
        view.addSubview(slider)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        panGesture.isEnabled = true
        
        view.addSubview(playButton)
        view.addSubview(closeButton)
        view.addSubview(selectLandmarksButton)
        view.addSubview(openChartButton)
        view.addSubview(selectAxisButton)
        view.addSubview(xAxisButton)
        view.addSubview(yAxisButton)
        view.addSubview(zAxisButton)
        view.addSubview(openAngleChartButton)
        view.addSubview(chartOpacitySlider)
        view.addSubview(currentLabel)
        view.addSubview(remainingLabel)
        
        angleDataList = [[], [], [], [], []]
        angleChartColors = [.clear, .clear, .clear, .clear, .clear]
        calculateAngles()
        
        player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.slider.value = Float(currentTime)
            self?.setTimeLables(time: time)
            self?.updateChartView()
        }
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
        }
    }
    
    func setScreenOrientation() {
        let asset = AVAsset(url: videoURL!)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        naturalSize = videoTrack.naturalSize
        let videoOrientation = videoTrack.preferredTransform
        videoAngle = atan2(videoOrientation.b, videoOrientation.a) * (180 / .pi)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if abs(videoAngle) == 90 {
            videoIsPortrait = true
            let factor = naturalSize.width / 375
            videoWidth = Int(naturalSize.height / factor)
            videoHeight = Int(naturalSize.width / factor)
            landmarkFrame = CGRect(x: ((Int(UIScreen.main.bounds.size.height) - videoWidth!) / 2), y: 0, width: videoWidth!, height: videoHeight!)
            appDelegate.orientationLock = .landscape
        } else if abs(videoAngle) == 0 {
            videoIsPortrait = false
            let factor = naturalSize.height / 375
            videoWidth = Int(naturalSize.width / factor)
            videoHeight = Int(naturalSize.height / factor)
            landmarkFrame = CGRect(x: ((Int(UIScreen.main.bounds.size.height) - videoWidth!) / 2), y: 0, width: videoWidth!, height: videoHeight!)
            appDelegate.orientationLock = .landscape
        } else if abs(videoAngle) == 180 {
            videoIsPortrait = false
            let factor = naturalSize.height / 375
            videoWidth = Int(naturalSize.width / factor)
            videoHeight = Int(naturalSize.height / factor)
            landmarkFrame = CGRect(x: ((Int(UIScreen.main.bounds.size.height) - videoWidth!) / 2), y: 0, width: videoWidth!, height: videoHeight!)
            appDelegate.orientationLock = .landscape
        }
    }
    
    func updateChartView() {
        if landmarksView.selectedCounter == 0 {
            landmarkDataList = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
        } else {
            var coordinates: [[Float]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            if buttonStates[2] == true {
                for i in 0..<landmarksView.selectedCounter {
                    for subArray in videoLandmarks3 {
                        let point = subArray[landmarksView.landmarkPoints[i]]
                        coordinates[i].append(point.x)
                    }
                }
            } else if buttonStates[3] == true {
                for i in 0..<landmarksView.selectedCounter {
                    for subArray in videoLandmarks3 {
                        let point = subArray[landmarksView.landmarkPoints[i]]
                        coordinates[i].append(point.y)
                    }
                }
            } else if buttonStates[4] == true {
                for i in 0..<landmarksView.selectedCounter {
                    for subArray in videoLandmarks3 {
                        let point = subArray[landmarksView.landmarkPoints[i]]
                        coordinates[i].append(point.z)
                    }
                }
            }
            landmarkDataList = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            for i in 0..<landmarksView.selectedCounter {
                var timeIndex = 0
                for point in coordinates[i] {
                    landmarkDataList[i].append(chartLandmarkData(landmarks: point, timestamps: videoTimestamps[timeIndex]))
                    timeIndex = timeIndex + 1
                }
            }
        }
        for view in self.chart.subviews {
            view.removeFromSuperview()
        }
        var controller = UIHostingController(rootView: LandmarkChart())
        chartView = controller.view
        if buttonStates[5] {
            var angleController = UIHostingController(rootView: AngleChart())
            chartView = angleController.view
        }
        chartView.frame = CGRect(x: 40, y: 20, width: Int(UIScreen.main.bounds.size.width) - 80, height: Int(UIScreen.main.bounds.size.height) - 80)
        chartView.backgroundColor = .clear
        chart.addSubview(chartView)
    }
    
    func updateLandmarks(for time: CMTime) {
        currentTimeMillis = Int(CMTimeGetSeconds(time) * 1000)
        videoPointMarkTime = currentTimeMillis
        if let index = videoTimestamps.firstIndex(where: { ($0 >= currentTimeMillis) && ($0 < (currentTimeMillis + 100))}) {
            let pixelCoordinates = videoLandmarks[index]
            let pointCoordinates = convertPixelsToPoints(pixelCoordinates)
            currentLandmarkIndex = index
            for i in 0..<landmarksView.selectedCounter {
                if buttonStates[2] {
                    videoPointMarks[i] = (videoLandmarks3[index][landmarksView.landmarkPoints[i]].x)
                } else if buttonStates[3] {
                    videoPointMarks[i] = (videoLandmarks3[index][landmarksView.landmarkPoints[i]].y)
                } else if buttonStates[4]{
                    videoPointMarks[i] = (videoLandmarks3[index][landmarksView.landmarkPoints[i]].z)
                }
            }
            if anglesGenerated {
                for i in 0..<5 {
                    anglePointMarks[i] = angleDataList[i][index].angles
                }
            }
            if firstFrame == true {
                landmarks = []
                for point in pointCoordinates {
                    landmarks.append(Landmark(point: point, color: .darkGray, selected: false))
                }
                landmarksView.landmarks = landmarks
                firstFrame = false
            } else {
                if landmarksView.landmarks.isEmpty {
                    landmarksView.landmarks = landmarkMemory
                }
                var i = 0
                for point in pointCoordinates {
                    landmarks[i] = Landmark(point: point, color: landmarksView.landmarks[i].color, selected: landmarksView.landmarks[i].selected)
                    i = i + 1
                }
                landmarksView.landmarks = landmarks
            }
            landmarksView.setNeedsDisplay()
        } else {
            if landmarksView.landmarks.isEmpty == false {
                landmarkMemory = landmarksView.landmarks
            }
            landmarksView.landmarks = []
            landmarksView.setNeedsDisplay()
        }
    }

    @objc func togglePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            hideButtonTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(hidePlayButton), userInfo: nil, repeats: false)
        } else {
            player.pause()
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            playButton.alpha = 1.0
            self.closeButton.alpha = 1.0
            self.slider.alpha = 1.0
            self.selectLandmarksButton.alpha = 1.0
            self.openChartButton.alpha = 1.0
            self.remainingLabel.alpha = 1.0
            self.currentLabel.alpha = 1.0
            self.xAxisButton.alpha = 1.0
            self.yAxisButton.alpha = 1.0
            self.zAxisButton.alpha = 1.0
            self.openAngleChartButton.alpha = 1.0
            self.chartOpacitySlider.alpha = 1.0
            self.selectAxisButton.alpha = 1.0
            hideButtonTimer?.invalidate()
        }
    }
    
    @objc func closePlayer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .portrait
        self.dismiss(animated: false)
    }
    
    @objc func openLanmarkSelection() {
        if buttonStates[0] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.green, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            landmarksView.touchIsActive = true
            buttonStates[0] = true
            playButton.isHidden = true
            openChartButton.isHidden = true
            slider.isHidden = true
            currentLabel.isHidden = true
            remainingLabel.isHidden = true
            panGesture.isEnabled = false
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            landmarksView.touchIsActive = false
            buttonStates[0] = false
            playButton.isHidden = false
            openChartButton.isHidden = false
            slider.isHidden = false
            currentLabel.isHidden = false
            remainingLabel.isHidden = false
            panGesture.isEnabled = true
            if landmarksView.selectedCounter > 0 {
                openChartButton.isHidden = false
            } else {
                openChartButton.isHidden = true
            }
        }
    }
    
    @objc func openChart() {
        if buttonStates[1] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = true
            playerView.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            landmarksView.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            selectLandmarksButton.isHidden = true
            selectAxisButton.isHidden = false
            chart.isHidden = false
            openAngleChartButton.isHidden = false
            chartOpacitySlider.isHidden = false
            videoPointMarkTime = currentTimeMillis
            for i in 0..<landmarksView.selectedCounter {
                if buttonStates[2] {
                    videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].x)
                } else if buttonStates[3] {
                    videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].y)
                } else if buttonStates[4]{
                    videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].z)
                }
            }
            updateChartView()
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = false
            playerView.layer.opacity = 1
            landmarksView.layer.opacity = 1
            selectLandmarksButton.isHidden = false
            selectAxisButton.isHidden = true
            xAxisButton.isHidden = true
            yAxisButton.isHidden = true
            zAxisButton.isHidden = true
            chart.isHidden = true
            openAngleChartButton.isHidden = true
            chartOpacitySlider.isHidden = true
        }
    }
    
    @objc func openAngleChart() {
        if buttonStates[5] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(named: "angle.button.selected")
            openAngleChartButton.setImage(image, for: .normal)
            xAxisButton.isHidden = true
            yAxisButton.isHidden = true
            zAxisButton.isHidden = true
            openChartButton.isHidden = true
            selectAxisButton.isHidden = true
            buttonStates[5].toggle()
            for i in 0..<5 {
                anglePointMarks[i] = angleDataList[i][currentLandmarkIndex].angles
            }
            updateChartView()
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(named: "angle.button")
            openAngleChartButton.setImage(image, for: .normal)
            openChartButton.isHidden = false
            selectAxisButton.isHidden = false
            buttonStates[5].toggle()
            updateChartView()
        }
    }
    
    @objc func selectAxis() {
        xAxisButton.isHidden.toggle()
        yAxisButton.isHidden.toggle()
        zAxisButton.isHidden.toggle()
        updateSelectAxisButton()
    }
    
    func updateSelectAxisButton() {
        if buttonStates[2] {
            selectAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .bold))?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
        } else if buttonStates[3] {
            selectAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .bold))?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
        } else if buttonStates[4] {
            selectAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .bold))?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    @objc func xAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.systemGreen.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = true
        buttonStates[3] = false
        buttonStates[4] = false
        videoPointMarkTime = currentTimeMillis
        for i in 0..<landmarksView.selectedCounter {
            videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].x)
        }
        updateSelectAxisButton()
        updateChartView()
    }
    
    @objc func yAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.systemGreen.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = false
        buttonStates[3] = true
        buttonStates[4] = false
        videoPointMarkTime = currentTimeMillis
        for i in 0..<landmarksView.selectedCounter {
            videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].y)
        }
        updateSelectAxisButton()
        updateChartView()
    }
    
    @objc func zAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.systemGreen.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = false
        buttonStates[3] = false
        buttonStates[4] = true
        videoPointMarkTime = currentTimeMillis
        for i in 0..<landmarksView.selectedCounter {
            videoPointMarks[i] = (videoLandmarks3[currentLandmarkIndex][landmarksView.landmarkPoints[i]].z)
        }
        updateSelectAxisButton()
        updateChartView()
    }
    
    @objc func videoDidEnd(notification: Notification) {
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    @objc func hidePlayButton() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.slider.alpha = 0.0
            self.selectLandmarksButton.alpha = 0.0
            self.openChartButton.alpha = 0.0
            self.remainingLabel.alpha = 0.0
            self.currentLabel.alpha = 0.0
            self.xAxisButton.alpha = 0.0
            self.yAxisButton.alpha = 0.0
            self.zAxisButton.alpha = 0.0
            self.openAngleChartButton.alpha = 0.0
            self.chartOpacitySlider.alpha = 0.0
            self.selectAxisButton.alpha = 0.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        playButton.alpha = 1.0
        self.closeButton.alpha = 1.0
        self.slider.alpha = 1.0
        self.selectLandmarksButton.alpha = 1.0
        self.openChartButton.alpha = 1.0
        self.remainingLabel.alpha = 1.0
        self.currentLabel.alpha = 1.0
        self.xAxisButton.alpha = 1.0
        self.yAxisButton.alpha = 1.0
        self.zAxisButton.alpha = 1.0
        self.openAngleChartButton.alpha = 1.0
        self.chartOpacitySlider.alpha = 1.0
        self.selectAxisButton.alpha = 1.0
        if player.timeControlStatus == .playing {
            hideButtonTimer?.invalidate()
            hideButtonTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hidePlayButton), userInfo: nil, repeats: false)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player.currentItem?.status == .readyToPlay {
                setScreenOrientation()
                duration = CMTimeGetSeconds(player.currentItem!.duration)
                self.setTimeLables(time: CMTime.zero)
                updateLandmarks(for: CMTime.zero)
                if !duration!.isNaN && duration! > 0 {
                    slider.maximumValue = Float(duration!)
                    slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                }
            }
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let delta = translation.x / view.bounds.height
        let sliderChange = Float(delta) * (slider.maximumValue - slider.minimumValue)
        if gesture.state == .changed {
            slider.value += sliderChange * 0.7
            gesture.setTranslation(.zero, in: view)
        }
        sliderValueChanged()
    }
    
    @objc func sliderValueChanged() {
        let seconds = Double(slider.value)
        let milliSeconds = seconds * 1000
        let targetTime = CMTime(value: CMTimeValue(milliSeconds), timescale: 1000)
        player.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    @objc func opacitySliderValueChanged() {
        let value = chartOpacitySlider.value
        self.chart.alpha = CGFloat(value / 100)
        playerView.layer.opacity = 1 - (value / 100)
        landmarksView.layer.opacity = 1 - (value / 100)
    }
    
    func convertPixelsToPoints(_ points: [CGPoint]) -> [CGPoint] {
        if videoIsPortrait == true {
            let scale = (UIScreen.main.scale) / (CGFloat(videoWidth!) / CGFloat(videoHeight!)) * 0.95
            return points.map { CGPoint(x: $0.x / scale, y: $0.y / scale) }
        } else if videoAngle == 180 {
            let scale = UIScreen.main.scale * 0.95
            let minusH = (videoWidth! / ((videoHeight!/375)))
            return points.map { CGPoint(x: (CGFloat(minusH) - ($0.y / scale)), y: ($0.x / scale) ) }
        } else {
            let scale = UIScreen.main.scale * 0.95
            let minusH = (videoHeight! / ((videoWidth!/375)))
            return points.map { CGPoint(x: ($0.y / scale) , y: (CGFloat(minusH) - ($0.x / scale))) }
        }
    }
    
    func setTimeLables(time: CMTime) {
        let currentTime = CMTimeGetSeconds(time)
        let currentMinutes = Int(currentTime) / 60
        let currentSeconds = Int(currentTime) % 60
        currentLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
        var remainingTime = 0
        if duration != nil {
            remainingTime = Int((duration!) - currentTime)
        }
        let remainingMinutes = Int(remainingTime) / 60
        var remainingSeconds = remainingTime
        if remainingTime >= 60 {
            remainingSeconds = Int(remainingTime) % 60
        }
        remainingLabel.text = "-" + String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
    }

    func calculateAngles() {
        if anglesGenerated == false {
            for (index, landmark) in videoLandmarks3.enumerated() {
                let angle1: Float = Float(angleBetweenVectors1(landmark[0], landmark[1], landmark[2]))
                let angle2: Float = Float(angleBetweenVectors1(landmark[0], landmark[5], landmark[6]))
                let angle3: Float = Float(angleBetweenVectors1(landmark[0], landmark[9], landmark[10]))
                let angle4: Float = Float(angleBetweenVectors1(landmark[0], landmark[13], landmark[14]))
                let angle5: Float = Float(angleBetweenVectors1(landmark[0], landmark[17], landmark[18]))
                angleDataList[0].append(chartAngleData(angles: angle1, timestamps: videoTimestamps[index]))
                angleDataList[1].append(chartAngleData(angles: angle2, timestamps: videoTimestamps[index]))
                angleDataList[2].append(chartAngleData(angles: angle3, timestamps: videoTimestamps[index]))
                angleDataList[3].append(chartAngleData(angles: angle4, timestamps: videoTimestamps[index]))
                angleDataList[4].append(chartAngleData(angles: angle5, timestamps: videoTimestamps[index]))
            }
            anglesGenerated.toggle()
        }
    }
    
    struct Landmark {
        var point: CGPoint
        var color: UIColor
        var selected: Bool
    }
    
    class LandmarksView: UIView {
    
        var landmarks: [Landmark] = []
        var touchIsActive = false
        var selectedCounter = 0
        var landmarkPoints: [Int] = []
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
            setupTapGestureRecognizer()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func setupTapGestureRecognizer() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGestureRecognizer.isEnabled = true
            addGestureRecognizer(tapGestureRecognizer)
        }
        
        @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if touchIsActive {
                let tapLocation = gestureRecognizer.location(in: self)
                let touchPoint = tapLocation
                if let nearestLandmark = nearestLandmark(to: touchPoint) {
                    if distance(from: nearestLandmark.point, to: touchPoint) < 20 {
                        if let index = landmarks.firstIndex(where: { $0.point == nearestLandmark.point }) {
                                if landmarks[index].selected {
                                    if landmarks[index].color == .systemRed {
                                        angleChartColors[0] = .clear
                                    } else if landmarks[index].color == .systemYellow {
                                        angleChartColors[1] = .clear
                                    } else if landmarks[index].color == .magenta {
                                        angleChartColors[2] = .clear
                                    } else if landmarks[index].color == .systemGreen {
                                        angleChartColors[3] = .clear
                                    } else if landmarks[index].color == .systemOrange {
                                        angleChartColors[4] = .clear
                                    }
                                    landmarks[index].color = .darkGray
                                    landmarks[index].selected.toggle()
                                    selectedCounter = selectedCounter - 1
                                    for (i, landmark) in landmarkPoints.enumerated() {
                                        if landmark == index {
                                            landmarkPoints.remove(at: i)
                                            chartColors.remove(at: i)
                                            chartColors.append(.clear)
                                            print(chartColors)
                                            fingerNumbers.remove(at: i)
                                            fingerNumbers.append(0)
                                        }
                                    }
                                } else if selectedCounter < 21 {
                                    if index == 0 {
                                        landmarks[index].color = .systemBlue
                                    } else if index >= 1 && index <= 4 {
                                        landmarks[index].color = .systemRed
                                        angleChartColors[0] = .systemRed
                                    } else if index >= 5 && index <= 8 {
                                        landmarks[index].color = .systemYellow
                                        angleChartColors[1] = .systemYellow
                                    } else if index >= 9 && index <= 12 {
                                        landmarks[index].color = .magenta
                                        angleChartColors[2] = .magenta
                                    } else if index >= 13 && index <= 16 {
                                        landmarks[index].color = .systemGreen
                                        angleChartColors[3] = .systemGreen
                                    } else if index >= 17 && index <= 20 {
                                        landmarks[index].color = .systemOrange
                                        angleChartColors[4] = .systemOrange
                                    }
                                    if index == 0 {
                                        fingerNumbers[selectedCounter] = 0
                                    } else if index == 4 || index == 8 || index == 12 || index == 16 || index == 20 {
                                        fingerNumbers[selectedCounter] = 4
                                    } else if index == 3 || index == 7 || index == 11 || index == 15 || index == 19 {
                                        fingerNumbers[selectedCounter] = 3
                                    } else if index == 2 || index == 6 || index == 10 || index == 14 || index == 18 {
                                        fingerNumbers[selectedCounter] = 2
                                    } else if index == 1 || index == 5 || index == 9 || index == 13 || index == 17 {
                                        fingerNumbers[selectedCounter] = 1
                                    }
                                    landmarks[index].selected.toggle()
                                    selectedCounter = selectedCounter + 1
                                    chartColors[selectedCounter - 1] = Color(landmarks[index].color)
                                    landmarkPoints.append(index)
                               }
                            if selectedCounter == 0 {
                                landmarkPoints = []
                            }
                            setNeedsDisplay()
                        }
                    }
                }
            }
        }
        
        private func commonInit() {
            isUserInteractionEnabled = true
        }
        
        override func draw(_ rect: CGRect) {
            guard !landmarks.isEmpty else { return }
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.gray.cgColor)
            context?.setLineWidth(2.0)
            let points = landmarks.map { $0.point }
            context?.move(to: points[0])
            context?.addLine(to: points[1])
            context?.addLine(to: points[2])
            context?.addLine(to: points[3])
            context?.addLine(to: points[4])
            context?.move(to: points[0])
            context?.addLine(to: points[5])
            context?.addLine(to: points[6])
            context?.addLine(to: points[7])
            context?.addLine(to: points[8])
            context?.move(to: points[0])
            context?.addLine(to: points[9])
            context?.addLine(to: points[10])
            context?.addLine(to: points[11])
            context?.addLine(to: points[12])
            context?.move(to: points[0])
            context?.addLine(to: points[13])
            context?.addLine(to: points[14])
            context?.addLine(to: points[15])
            context?.addLine(to: points[16])
            context?.move(to: points[0])
            context?.addLine(to: points[17])
            context?.addLine(to: points[18])
            context?.addLine(to: points[19])
            context?.addLine(to: points[20])
            context?.strokePath()
            for (index, landmark) in landmarks.enumerated() {
                let circleRect = CGRect(x: landmark.point.x - 5, y: landmark.point.y - 5, width: 10, height: 10)
                context?.setFillColor(landmark.color.cgColor)
                context?.fillEllipse(in: circleRect)
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8),
                    .foregroundColor: UIColor.black
                ]
                var text = "0" as NSString
                if index == 4 || index == 8 || index == 12 || index == 16 || index == 20 {
                    text = "4"
                } else if index == 3 || index == 7 || index == 11 || index == 15 || index == 19 {
                    text = "3"
                } else if index == 2 || index == 6 || index == 10 || index == 14 || index == 18 {
                    text = "2"
                } else if index == 1 || index == 5 || index == 9 || index == 13 || index == 17 {
                    text = "1"
                }
                let textSize = text.size(withAttributes: textAttributes)
                let textRect = CGRect(x: landmark.point.x - textSize.width / 2, y: landmark.point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
                text.draw(in: textRect, withAttributes: textAttributes)
            }
        }
        
        func nearestLandmark(to point: CGPoint) -> Landmark? {
            return landmarks.min { landmark1, landmark2 in
                distance(from: landmark1.point, to: point) < distance(from: landmark2.point, to: point)
            }
        }
        
        func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
            return hypot(point2.x - point1.x, point2.y - point1.y)
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if nearestLandmark(to: point) != nil {
                return self
            }
            return super.hitTest(point, with: event)
        }
    }
}

class CustomSlider: UISlider {
    
    var customTrackHeight: CGFloat = 13
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var customBounds = super.trackRect(forBounds: bounds)
        customBounds.size.height = customTrackHeight
        return customBounds
    }
}
