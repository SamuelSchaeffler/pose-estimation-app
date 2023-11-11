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
    var videoWidth: Int?
    var videoHeight: Int?
    var videoIsPortrait: Bool?
    var hideButtonTimer: Timer?
    var timeObserverToken: Any?
    var buttonStates: [Bool] = [false, false, true, false, false]
    var landmarksView: LandmarksView!
    var landmarkFrame: CGRect?
    var videoTimestamps: [Int]!
    var videoLandmarks: [[CGPoint]]!
    var videoLandmarks3: [[SCNVector3]] = []
    var landmarks: [Landmark] = []
    var landmarkMemory: [Landmark] = []
    var firstFrame: Bool = true
    
    var videoURL: URL?
    
    var playerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        return view
    }()
    
    var chartView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        return view
    }()
    
    var chart: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        //view.backgroundColor = .white.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    var playButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "pause.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - buttonWidth) / 2, y: (UIScreen.main.bounds.size.width - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)
        return button
    }()
    var closeButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        let buttonWidth: CGFloat = 20
        let buttonHeight: CGFloat = 20
        button.frame = CGRect(x: 20, y: 20, width: buttonWidth, height: buttonHeight)
        return button
    }()
    
    var slider: UISlider = {
        let frame = CGRect(x: 40, y: UIScreen.main.bounds.size.width - 60, width: UIScreen.main.bounds.size.height - 80, height: 24)
        let slider = CustomSlider(frame: frame)
        slider.customTrackHeight = 13
        let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        slider.setThumbImage(thumbImage, for: .normal)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    var currentLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 45, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    var remainingLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: UIScreen.main.bounds.size.height - 95, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    var selectLandmarksButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openLanmarkSelection), for: .touchUpInside)
        let buttonWidth: CGFloat = 36
        let buttonHeight: CGFloat = 32
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 120), y: (UIScreen.main.bounds.size.width - 85), width: buttonWidth, height: buttonHeight)
        return button
    }()
    var openChartButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(openChart), for: .touchUpInside)
        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 70), y: (UIScreen.main.bounds.size.width - 85), width: buttonWidth, height: buttonHeight)
        return button
    }()
    var zAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "z.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(zAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 25
        let buttonHeight: CGFloat = 25
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 67.5), y: (UIScreen.main.bounds.size.width - 115), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    var yAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "y.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(yAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 25
        let buttonHeight: CGFloat = 25
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 67.5), y: (UIScreen.main.bounds.size.width - 140), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
    }()
    var xAxisButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold)
        let image = UIImage(systemName: "x.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(xAxisSelected), for: .touchUpInside)
        let buttonWidth: CGFloat = 25
        let buttonHeight: CGFloat = 25
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 67.5), y: (UIScreen.main.bounds.size.width - 165), width: buttonWidth, height: buttonHeight)
        button.isHidden = true
        return button
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
        landmarksView.backgroundColor = .clear//.systemPink.withAlphaComponent(0.5)
        landmarksView.isUserInteractionEnabled = true
        view.addSubview(landmarksView)
        
        let landmarkInterval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: landmarkInterval, queue: DispatchQueue.main) { [weak self] time in
            self?.updateLandmarks(for: time)
        }
        
        view.addSubview(chart)
        
        
        view.addSubview(playButton)
        view.addSubview(closeButton)
        view.addSubview(selectLandmarksButton)
        view.addSubview(openChartButton)
        view.addSubview(xAxisButton)
        view.addSubview(yAxisButton)
        view.addSubview(zAxisButton)
        
        view.addSubview(slider)
        view.addSubview(currentLabel)
        view.addSubview(remainingLabel)
        player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.slider.value = Float(currentTime)
            
            let currentMinutes = Int(currentTime) / 60
            let currentSeconds = Int(currentTime) % 60
            self?.currentLabel.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)

            var remainingTime = 0
            if self?.duration != nil {
                remainingTime = Int((self?.duration!)! - currentTime)
            }
            let remainingMinutes = Int(remainingTime) / 60
            var remainingSeconds = remainingTime
            if remainingTime >= 60 {
                remainingSeconds = Int(remainingTime) % 60
            }
            self?.remainingLabel.text = "-" + String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
            self?.updateChartView()
        }
        player.play()
    }
    deinit {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
        }
    }
    
    func setScreenOrientation() {
        let asset = AVAsset(url: videoURL!)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let naturalSize = videoTrack.naturalSize
        let videoOrientation = videoTrack.preferredTransform
        let videoAngle = atan2(videoOrientation.b, videoOrientation.a)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if abs(videoAngle) == .pi / 2 {
            // Hochformat
            videoIsPortrait = true
            let factor = naturalSize.width / 375
            videoWidth = Int(naturalSize.height / factor)
            videoHeight = Int(naturalSize.width / factor)
            landmarkFrame = CGRect(x: ((Int(UIScreen.main.bounds.size.height) - videoWidth!) / 2), y: 0, width: videoWidth!, height: videoHeight!)
            appDelegate.orientationLock = .landscape
        } else {
            // Querformat
            videoIsPortrait = false
            let factor = naturalSize.height / 375
            videoWidth = Int(naturalSize.width / factor)
            videoHeight = Int(naturalSize.height / factor)
            landmarkFrame = CGRect(x: ((Int(UIScreen.main.bounds.size.height) - videoWidth!) / 2), y: 0, width: videoWidth!, height: videoHeight!)
            appDelegate.orientationLock = .landscape
        }
    }
    
    func updateChartView() {
        if landmarksView.selectedLandmarkIndex == nil {
            dataList = []
        } else {
            let landmarkPoint = landmarksView.selectedLandmarkIndex!
            var coordinates: [Float] = []
            if buttonStates[2] == true {
                //x
                for subArray in videoLandmarks3 {
                    let point = subArray[landmarkPoint]
                    coordinates.append(point.x)
                }
            } else if buttonStates[3] == true {
                //y
                for subArray in videoLandmarks3 {
                    let point = subArray[landmarkPoint]
                    coordinates.append(point.y)
                }
            } else if buttonStates[4] == true {
                //z
                for subArray in videoLandmarks3 {
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
        }
        for view in self.chart.subviews {
            view.removeFromSuperview()
        }
        let controller = UIHostingController(rootView: LandmarkChart())
        chartView = controller.view
        chartView.frame = CGRect(x: 40, y: 20, width: Int(UIScreen.main.bounds.size.width) - 80, height: Int(UIScreen.main.bounds.size.height) - 80)
        chartView.backgroundColor = .clear
        chart.addSubview(chartView)
    }
    
    func updateLandmarks(for time: CMTime) {
        currentTimeMillis = Int(CMTimeGetSeconds(time) * 1000)
        videoPointMark.1 = currentTimeMillis
        if let index = videoTimestamps.firstIndex(where: { ($0 >= currentTimeMillis) && ($0 < (currentTimeMillis + 100))}) {
            let pixelCoordinates = videoLandmarks[index]
            let pointCoordinates = convertPixelsToPoints(pixelCoordinates)
            currentLandmarkIndex = index
            if landmarksView.selectedLandmarkIndex != nil {
                if buttonStates[2] {
                    videoPointMark.0 = (videoLandmarks3[index][landmarksView.selectedLandmarkIndex!].x)
                } else if buttonStates[3] {
                    videoPointMark.0 = (videoLandmarks3[index][landmarksView.selectedLandmarkIndex!].y)
                } else if buttonStates[4]{
                    videoPointMark.0 = (videoLandmarks3[index][landmarksView.selectedLandmarkIndex!].z)
                }
            }
            
            
            if firstFrame == true {
                landmarks = []
                for point in pointCoordinates {
                    landmarks.append(Landmark(point: point, color: .red))
                }
                landmarksView.landmarks = landmarks
                firstFrame = false
            } else {
                if landmarksView.landmarks.isEmpty {
                    landmarksView.landmarks = landmarkMemory
                }
                var i = 0
                for point in pointCoordinates {
                    landmarks[i] = Landmark(point: point, color: landmarksView.landmarks[i].color)
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
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.green, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            
            landmarksView.touchIsActive = true
            
            buttonStates[0] = true
            playButton.isHidden = true
            openChartButton.isHidden = true
            slider.isHidden = true
            currentLabel.isHidden = true
            remainingLabel.isHidden = true
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            
            landmarksView.touchIsActive = false
            
            buttonStates[0] = false
            playButton.isHidden = false
            openChartButton.isHidden = false
            slider.isHidden = false
            currentLabel.isHidden = false
            remainingLabel.isHidden = false
        }
        
        
    }
    @objc func openChart() {
        if buttonStates[1] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = true
            
            playerView.layer.opacity = 0.2
            landmarksView.layer.opacity = 0.2
            
            selectLandmarksButton.isHidden = true
            xAxisButton.isHidden = false
            yAxisButton.isHidden = false
            zAxisButton.isHidden = false
            chart.isHidden = false
            
            videoPointMark.1 = currentTimeMillis
            if buttonStates[2] {
                videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].x)
            } else if buttonStates[3] {
                videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].y)
            } else {
                videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].z)
            }
            
            
            updateChartView()
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = false
            
            playerView.layer.opacity = 1.0
            landmarksView.layer.opacity = 1.0
            
            selectLandmarksButton.isHidden = false
            xAxisButton.isHidden = true
            yAxisButton.isHidden = true
            zAxisButton.isHidden = true
            chart.isHidden = true
        }
    }
    
    @objc func xAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = true
        buttonStates[3] = false
        buttonStates[4] = false
        
        videoPointMark.1 = currentTimeMillis
        videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].x)
        
        updateChartView()
    }
    @objc func yAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = false
        buttonStates[3] = true
        buttonStates[4] = false
        
        videoPointMark.1 = currentTimeMillis
        videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].y)
        
        updateChartView()
    }
    @objc func zAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold))?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = false
        buttonStates[3] = false
        buttonStates[4] = true
        
        videoPointMark.1 = currentTimeMillis
        videoPointMark.0 = (videoLandmarks3[currentLandmarkIndex][landmarksView.selectedLandmarkIndex ?? 0].z)
        
        updateChartView()
    }
    
    @objc func videoDidEnd(notification: Notification) {
        player.seek(to: CMTime.zero)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
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
                if !duration!.isNaN && duration! > 0 {
                    slider.maximumValue = Float(duration!)
                    slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                }
            }
        }
    }
    @objc func sliderValueChanged() {
        let seconds = Double(slider.value)
        let targetTime = CMTime(value: CMTimeValue(seconds), timescale: 1)
        player.seek(to: targetTime)
    }
    
    func convertPixelsToPoints(_ points: [CGPoint]) -> [CGPoint] {
        if videoIsPortrait == true {
            let scale = (UIScreen.main.scale) / (CGFloat(videoWidth!) / CGFloat(videoHeight!))
            return points.map { CGPoint(x: $0.x / scale, y: $0.y / scale) }
        } else {
            let scale = UIScreen.main.scale
            let minus = videoHeight! / (videoWidth!/375)
            return points.map { CGPoint(x: ($0.y / scale), y: CGFloat(minus) - ($0.x / scale)) }
        }
    }

    class CustomSlider: UISlider {
        var customTrackHeight: CGFloat = 10
        override func trackRect(forBounds bounds: CGRect) -> CGRect {
            var customBounds = super.trackRect(forBounds: bounds)
            customBounds.size.height = customTrackHeight
            return customBounds
        }
    }
    struct Landmark {
        var point: CGPoint
        var color: UIColor
    }
    class LandmarksView: UIView {
        
        var landmarks: [Landmark] = []
        var touchIsActive = false
        var landmarkSelected = false
        var selectedLandmarkIndex: Int?
        
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
            print("setup TapGestureRecognizer")
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGestureRecognizer.isEnabled = true
            addGestureRecognizer(tapGestureRecognizer)
        }
        
        @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if touchIsActive {
                let tapLocation = gestureRecognizer.location(in: self)
                // ... finde die nächste Landmarke und ändere ihre Farbe ...
                print("handle Tap Location: \(tapLocation)")
                let touchPoint = tapLocation
                if let nearestLandmark = nearestLandmark(to: touchPoint) {
                    print(nearestLandmark)
                    if distance(from: nearestLandmark.point, to: touchPoint) < 20 {  // Reaktionsradius definieren
                        
                        // Die Farbe der nächsten Landmarke ändern
                        if let index = landmarks.firstIndex(where: { $0.point == nearestLandmark.point }) {
                            print("change Color")
                            
                            if landmarkSelected == false {
                                landmarkSelected = true
                                landmarks[index].color = .green //landmarks[index].color == .red ? .green : .red
                                selectedLandmarkIndex = index
                            } else {
                                if landmarks[index].color == .green {
                                    landmarkSelected = false
                                    landmarks[index].color = .red
                                    selectedLandmarkIndex = nil
                                }
                            }
                            setNeedsDisplay()  // Ansicht neu zeichnen
                        }
                    }
                }
            }
        }
        
        private func commonInit() {
            isUserInteractionEnabled = true  // Benutzerinteraktion ermöglichen
        }
        override func draw(_ rect: CGRect) {
            guard !landmarks.isEmpty else { return }
            
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.gray.cgColor)  // Farbe für Linien
            context?.setLineWidth(2.0)  // Linienbreite
            
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
            
            context?.strokePath()  // Führt den Zeichnungsvorgang aus
            
            //context?.setFillColor(UIColor.red.cgColor)  // Farbe für Punkte
            
            for landmark in landmarks {  // Zeichne die Punkte
                let circleRect = CGRect(x: landmark.point.x - 5, y: landmark.point.y - 5, width: 10, height: 10)
                context?.setFillColor(landmark.color.cgColor)
                context?.fillEllipse(in: circleRect)
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




