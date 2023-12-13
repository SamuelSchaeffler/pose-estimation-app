//
//  VideoComparisonViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 02.12.23.
//

import UIKit
import SwiftUI
import SceneKit
import AVFoundation

class VideoComparisonViewController: UIViewController {

    var video1URL: URL?
    var video2URL: URL?
    var video1Landmarks: [[CGPoint]]?
    var video2Landmarks: [[CGPoint]]?
    var video1Landmarks3: [[SCNVector3]] = []
    var video2Landmarks3: [[SCNVector3]] = []
    var video1Timestamps: [Int] = []
    var video2Timestamps: [Int] = []
    
    var filteredVideo1Landmarks3: [[SCNVector3]] = []
    var filteredVideo2Landmarks3: [[SCNVector3]] = []
    
    var player1: AVPlayer!
    var player2: AVPlayer!
    var currentTimeMillis1: Int = 0
    var currentTimeMillis2: Int = 0
    var timeObserverToken1: Any?
    var timeObserverToken2: Any?
    var video1Ended = false
    var video2Ended = false
    var duration1: Float64?
    var duration2: Float64?
    var video1Loaded = false
    var video2Loaded = false

    var landmarksView1: LandmarksView!
    var landmarksView2: LandmarksView!
    var landmarkFrame1: CGRect?
    var landmarkFrame2: CGRect?
    var landmarks1: [Landmark] = []
    var landmarks2: [Landmark] = []
    var landmarkMemory1: [Landmark] = []
    var landmarkMemory2: [Landmark] = []
    var firstFrame1: Bool = true
    var firstFrame2: Bool = true
    var videoAngle1: CGFloat = 0
    var videoAngle2: CGFloat = 0
    var videoWidth1: Int?
    var videoWidth2: Int?
    var videoHeight1: Int?
    var videoHeight2: Int?
    
    let scene1 = SCNScene()
    let scene2 = SCNScene()
    var sceneViewOpacityView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    var buttonStates: [Bool] = [false, false, true, false, false, false, false, false]
    var landmarkColors: [UIColor] = [.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray,.darkGray]
    var selectedLandmarksCounter = 0
    var selectedLandmarkPoints: [Int] = []
    var currentLandmarkIndex1: Int = 0
    var currentLandmarkIndex2: Int = 0

    
    var tapGesture1: UITapGestureRecognizer!
    var tapGesture2: UITapGestureRecognizer!
    
    var sceneView1 = SCNView()
    var sceneView2 = SCNView()
    
    var playerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        view.isHidden = true
        return view
    }()
    var closeButton: UIButton = {
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
    var playButton: UIButton = {
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
    var selectLandmarksButton: UIButton = {
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
    var slider1: UISlider = {
        let frame = CGRect(x: 40, y: UIScreen.main.bounds.size.width - 60, width: (UIScreen.main.bounds.size.height / 2) - 80, height: 24)
        let slider = CustomSlider(frame: frame)
        slider.customTrackHeight = 13
        let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "maxTrackImage0.5"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "minTrackImage0.5"), for: .normal)
        slider.addTarget(self, action: #selector(slider1ValueChanged), for: .valueChanged)
        return slider
    }()
    var slider2: UISlider = {
        let frame = CGRect(x: (UIScreen.main.bounds.size.height / 2) + 40, y: UIScreen.main.bounds.size.width - 60, width: (UIScreen.main.bounds.size.height / 2) - 80, height: 24)
        let slider = CustomSlider(frame: frame)
        slider.customTrackHeight = 13
        let thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "maxTrackImage0.5"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "minTrackImage0.5"), for: .normal)
        slider.addTarget(self, action: #selector(slider2ValueChanged), for: .valueChanged)
        return slider
    }()
    
    var currentLabel1: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 45, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    var remainingLabel1: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (UIScreen.main.bounds.size.height / 2) - 95, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    var currentLabel2: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: (UIScreen.main.bounds.size.height / 2) + 45, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    var remainingLabel2: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: UIScreen.main.bounds.size.height - 95, y: UIScreen.main.bounds.size.width - 40, width: 50, height: 24)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    var connectSlidersButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "lock.open.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(connectSliders), for: .touchUpInside)
        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - buttonWidth) / 2, y: UIScreen.main.bounds.size.width - 50, width: buttonWidth, height: buttonHeight)
        return button
    }()

    
    var showPlayerButton: UIButton = {
        let button = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
        let image = UIImage(systemName: "video.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(showPlayer), for: .touchUpInside)
        let buttonWidth: CGFloat = 38
        let buttonHeight: CGFloat = 38
        button.frame = CGRect(x: (UIScreen.main.bounds.size.height - 78), y: 15, width: buttonWidth, height: buttonHeight)
        return button
    }()
    
    var openChartButton: UIButton = {
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
    var selectAxisButton: UIButton = {
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
    var zAxisButton: UIButton = {
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
    var yAxisButton: UIButton = {
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
    var xAxisButton: UIButton = {
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
    
    var chartView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        return view
    }()
    var chart: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        view.isHidden = true
        return view
    }()
    
    var chartOpacitySlider: UISlider = {
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

    var openAngleChartButton: UIButton = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .landscape
        
        player1 = AVPlayer(url: video1URL!)
        player2 = AVPlayer(url: video2URL!)
        let playerLayer1 = AVPlayerLayer(player: player1)
        let playerLayer2 = AVPlayerLayer(player: player2)
        playerLayer1.frame = CGRect(x: 0, y: 0, width: (Int(UIScreen.main.bounds.size.height / 2)), height: Int(UIScreen.main.bounds.size.width))
        playerLayer2.frame = CGRect(x: (Int(UIScreen.main.bounds.size.height) / 2), y: 0, width: (Int(UIScreen.main.bounds.size.height) / 2), height: Int(UIScreen.main.bounds.size.width))
        playerView.layer.addSublayer(playerLayer1)
        playerView.layer.addSublayer(playerLayer2)
        view.addSubview(playerView)
    
        landmarkFrame1 = calculateVideoFrame(in: playerLayer1.frame, videoURL: video1URL!, videoN: 1)
        landmarkFrame2 = calculateVideoFrame(in: playerLayer2.frame, videoURL: video2URL!, videoN: 2)
        landmarksView1 = LandmarksView(frame: landmarkFrame1!)
        landmarksView2 = LandmarksView(frame: landmarkFrame2!)
        landmarksView1.backgroundColor = .clear
        landmarksView2.backgroundColor = .clear
        landmarksView1.isHidden = true
        landmarksView2.isHidden = true
        view.addSubview(landmarksView1)
        view.addSubview(landmarksView2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(video1DidEnd), name: .AVPlayerItemDidPlayToEndTime, object: player1.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(video2DidEnd), name: .AVPlayerItemDidPlayToEndTime, object: player2.currentItem)
        
        let landmarkInterval1 = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
        timeObserverToken1 = player1.addPeriodicTimeObserver(forInterval: landmarkInterval1, queue: DispatchQueue.main) { [weak self] time in
            self?.updateLandmarks1(for: time)
            let currentTime = CMTimeGetSeconds(time)
            self?.slider1.value = Float(currentTime)
            
            self!.setTimeLables(time: time, player: 1)
            
            self?.updateChartView()
        }
        let landmarkInterval2 = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
        timeObserverToken2 = player2.addPeriodicTimeObserver(forInterval: landmarkInterval2, queue: DispatchQueue.main) { [weak self] time in
            self?.updateLandmarks2(for: time)
            let currentTime = CMTimeGetSeconds(time)
            self?.slider2.value = Float(currentTime)
            
            self!.setTimeLables(time: time, player: 2)
            
            self?.updateChartView()
        }
        
        player1.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        player2.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        let frame1 = CGRect(x: 0, y: 0, width: (Int(UIScreen.main.bounds.size.height) / 2), height: Int(UIScreen.main.bounds.size.width))
        sceneView1 = SCNView(frame: frame1)
        sceneView1.backgroundColor = UIColor.clear
        sceneView1.scene = scene1
        sceneView1.allowsCameraControl = true
        sceneView1.pointOfView?.camera?.automaticallyAdjustsZRange = true
        let cameraNode1 = SCNNode()
        cameraNode1.camera = SCNCamera()
        cameraNode1.position = SCNVector3(0, 0, calculateCameraSize(landmarks: video1Landmarks3))
        cameraNode1.eulerAngles = SCNVector3(x: Float.pi, y: 0, z: 0)
        cameraNode1.camera?.fieldOfView = 60
        cameraNode1.camera?.usesOrthographicProjection = true
        cameraNode1.camera?.orthographicScale = 100
        
        scene1.rootNode.addChildNode(cameraNode1)
        sceneView1.pointOfView = cameraNode1
        sceneView1.pointOfView?.camera?.automaticallyAdjustsZRange = true
        
        let frame2 = CGRect(x: (Int(UIScreen.main.bounds.size.height) / 2), y: 0, width: (Int(UIScreen.main.bounds.size.height) / 2), height: Int(UIScreen.main.bounds.size.width))
        sceneView2 = SCNView(frame: frame2)
        sceneView2.backgroundColor = UIColor.clear
        sceneView2.scene = scene2
        sceneView2.allowsCameraControl = true
        sceneView2.pointOfView?.camera?.automaticallyAdjustsZRange = true
        let cameraNode2 = SCNNode()
        cameraNode2.camera = SCNCamera()
        cameraNode2.position = SCNVector3(0, 0, calculateCameraSize(landmarks: video2Landmarks3))
        cameraNode2.eulerAngles = SCNVector3(x: Float.pi, y: 0, z: 0)
        cameraNode2.camera?.fieldOfView = 60
        cameraNode2.camera?.usesOrthographicProjection = true
        cameraNode2.camera?.orthographicScale = 100
        
        scene2.rootNode.addChildNode(cameraNode2)
        sceneView2.pointOfView = cameraNode2
        sceneView2.pointOfView?.camera?.automaticallyAdjustsZRange = true
        
        addCoordinateSystem(toScene: scene1)
        addCoordinateSystem(toScene: scene2)
        
        addPoints(coordinates: video1Landmarks3[0], toScene: scene1, color: landmarkColors)
        addPoints(coordinates: video2Landmarks3[0], toScene: scene2, color: landmarkColors)
        
        view.addSubview(sceneView1)
        view.addSubview(sceneView2)
        //view.addSubview(sceneViewOpacityView)
        view.addSubview(chart)
        
        view.addSubview(closeButton)
        view.addSubview(playButton)
        view.addSubview(slider1)
        view.addSubview(slider2)
        view.addSubview(currentLabel1)
        view.addSubview(remainingLabel1)
        view.addSubview(currentLabel2)
        view.addSubview(remainingLabel2)
        view.addSubview(connectSlidersButton)
        view.addSubview(selectLandmarksButton)
        view.addSubview(showPlayerButton)
        view.addSubview(openChartButton)
        view.addSubview(selectAxisButton)
        view.addSubview(xAxisButton)
        view.addSubview(yAxisButton)
        view.addSubview(zAxisButton)
        view.addSubview(chartOpacitySlider)
        view.addSubview(openAngleChartButton)

        
        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView1.addGestureRecognizer(tapGesture1)
        sceneView2.addGestureRecognizer(tapGesture2)
        tapGesture1.isEnabled = false
        tapGesture2.isEnabled = false

        comparisonVideo1PointMarks = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        comparisonVideo2PointMarks = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        angleDataList = [[], [], [], [], []]
        angleChartColors = [.clear, .clear, .clear, .clear, .clear]
        
        
//        filteredVideo1Landmarks3 = applyKalmanFilter(to: video1Landmarks3, q: 0.1, r: 0.8, initialP: 1.0)
//        video1Landmarks3 = filteredVideo1Landmarks3
        
//        filteredVideo2Landmarks3 = applyKalmanFilter3D(to: video2Landmarks3, q: 0.5, r: 0.1, initialP: 1.0)
//        video2Landmarks3 = filteredVideo2Landmarks3
        
        
        calculateAngles()
        
    }
    
    @objc func closePlayer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.orientationLock = .portrait
        self.dismiss(animated: false)
    }
    @objc func togglePlayPause() {
        if player1.timeControlStatus == .paused {
            player1.play()
            player2.play()
            playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            player1.pause()
            player2.pause()
            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    @objc func video1DidEnd(notification: Notification) {
        //player1.pause()
        player1.seek(to: CMTime.zero)
        player1.play()
//        video1Ended = true
//        if video2Ended {
//            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
//            video1Ended = false
//            video2Ended = false
//        }
    }
    @objc func video2DidEnd(notification: Notification) {
        //player2.pause()
        player2.seek(to: CMTime.zero)
        player2.play()
//        video2Ended = true
//        if video1Ended {
//            playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
//            video1Ended = false
//            video2Ended = false
//        }
    }
    
    @objc func openLanmarkSelection() {
        if buttonStates[0] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.green, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            
            buttonStates[0] = true
            playButton.isHidden = true
            openChartButton.isHidden = true
            showPlayerButton.isHidden = true
            slider1.isHidden = true
            slider2.isHidden = true
            remainingLabel1.isHidden = true
            remainingLabel2.isHidden = true
            currentLabel1.isHidden = true
            currentLabel2.isHidden = true
            tapGesture1.isEnabled = true
            tapGesture2.isEnabled = true
            connectSlidersButton.isHidden = true
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            let image = UIImage(systemName: "dot.circle.and.hand.point.up.left.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            selectLandmarksButton.setImage(image, for: .normal)
            
            buttonStates[0] = false
            playButton.isHidden = false
            openChartButton.isHidden = false
            showPlayerButton.isHidden = false
            slider1.isHidden = false
            slider2.isHidden = false
            remainingLabel1.isHidden = false
            remainingLabel2.isHidden = false
            currentLabel1.isHidden = false
            currentLabel2.isHidden = false
            tapGesture1.isEnabled = false
            tapGesture2.isEnabled = false
            connectSlidersButton.isHidden = false
            
            if selectedLandmarksCounter > 0 {
                openChartButton.isHidden = false
            } else {
                openChartButton.isHidden = true
            }
        }
        
        
    }
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let scnView = gestureRecognize.view as! SCNView
        let location = gestureRecognize.location(in: scnView)
        let options: [SCNHitTestOption: Any] = [.boundingBoxOnly: true, .searchMode: SCNHitTestSearchMode.all.rawValue]
        let hitResults = scnView.hitTest(location, options: options)
        if let hitResult = hitResults.first {
            let node = hitResult.node
            if node.geometry is SCNSphere {
                let name = node.name
                let index = Int(name!)!
                
                
                
                
                if landmarkColors[index] == .darkGray {
                    selectedLandmarkPoints.append(index)
                    if index == 0 {
                        landmarkColors[index] = .systemBlue
                        landmarksView1.landmarks[index].color = .systemBlue
                        landmarksView2.landmarks[index].color = .systemBlue
                    } else if index >= 1 && index <= 4 {
                        landmarkColors[index] = .systemRed
                        angleChartColors[0] = .systemRed
                        landmarksView1.landmarks[index].color = .systemRed
                        landmarksView2.landmarks[index].color = .systemRed
                    } else if index >= 5 && index <= 8 {
                        landmarkColors[index] = .systemYellow
                        angleChartColors[1] = .systemYellow
                        landmarksView1.landmarks[index].color = .systemYellow
                        landmarksView2.landmarks[index].color = .systemYellow
                    } else if index >= 9 && index <= 12 {
                        landmarkColors[index] = .magenta
                        angleChartColors[2] = .magenta
                        landmarksView1.landmarks[index].color = .magenta
                        landmarksView2.landmarks[index].color = .magenta
                    } else if index >= 13 && index <= 16 {
                        landmarkColors[index] = .systemGreen
                        angleChartColors[3] = .systemGreen
                        landmarksView1.landmarks[index].color = .systemGreen
                        landmarksView2.landmarks[index].color = .systemGreen
                    } else if index >= 17 && index <= 20 {
                        landmarkColors[index] = .systemOrange
                        angleChartColors[4] = .systemOrange
                        landmarksView1.landmarks[index].color = .systemOrange
                        landmarksView2.landmarks[index].color = .systemOrange
                    }
                    chartColors[selectedLandmarksCounter] = Color(landmarkColors[index])
                    
                    if index == 0 {
                        fingerNumbers[selectedLandmarksCounter] = 0
                    } else if index == 4 || index == 8 || index == 12 || index == 16 || index == 20 {
                        fingerNumbers[selectedLandmarksCounter] = 4
                    } else if index == 3 || index == 7 || index == 11 || index == 15 || index == 19 {
                        fingerNumbers[selectedLandmarksCounter] = 3
                    } else if index == 2 || index == 6 || index == 10 || index == 14 || index == 18 {
                        fingerNumbers[selectedLandmarksCounter] = 2
                    } else if index == 1 || index == 5 || index == 9 || index == 13 || index == 17 {
                        fingerNumbers[selectedLandmarksCounter] = 1
                    }
                    
                    selectedLandmarksCounter += 1
                    
                } else {
                    
                    if landmarkColors[index] == .systemRed {
                        angleChartColors[0] = .clear
                    } else if landmarkColors[index] == .systemYellow {
                        angleChartColors[1] = .clear
                    } else if landmarkColors[index] == .magenta {
                        angleChartColors[2] = .clear
                    } else if landmarkColors[index] == .systemGreen {
                        angleChartColors[3] = .clear
                    } else if landmarkColors[index] == .systemOrange {
                        angleChartColors[4] = .clear
                    }
                    
                    landmarksView1.landmarks[index].color = .darkGray
                    landmarksView2.landmarks[index].color = .darkGray
                    landmarkColors[index] = .darkGray
                    selectedLandmarksCounter -= 1
                    
                    for (i, landmark) in selectedLandmarkPoints.enumerated() {
                        if landmark == index {
                            selectedLandmarkPoints.remove(at: i)
                            chartColors.remove(at: i)
                            chartColors.append(.clear)
                            fingerNumbers.remove(at: i)
                            fingerNumbers.append(0)
                        }
                    }
                }
                updateLandmarks1(for: player1.currentTime())
                updateLandmarks2(for: player2.currentTime())
            }
        }
    }
    @objc func slider1ValueChanged() {
        let seconds = Double(slider1.value)
        let milliSeconds = seconds * 1000
        let targetTime = CMTime(value: CMTimeValue(milliSeconds), timescale: 1000)
        player1.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if buttonStates[7] == true {
            let value = seconds / duration1!
            let time = CMTime(value: CMTimeValue((value * duration2!) * 1000), timescale: 1000)
            player2.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    @objc func slider2ValueChanged() {
        let seconds = Double(slider2.value)
        let milliSeconds = seconds * 1000
        let targetTime = CMTime(value: CMTimeValue(milliSeconds), timescale: 1000)
        player2.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if buttonStates[7] == true {
            let value = seconds / duration2!
            let time = CMTime(value: CMTimeValue((value * duration1!) * 1000), timescale: 1000)
            player1.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }

    @objc func openChart() {
        if buttonStates[1] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = true
            
            playerView.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            landmarksView1.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            landmarksView2.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            sceneView1.layer.opacity = 1 - (chartOpacitySlider.value / 100)
            sceneView2.layer.opacity = 1 - (chartOpacitySlider.value / 100)

            selectLandmarksButton.isHidden = true
            
            showPlayerButton.isHidden = true
            
            selectAxisButton.isHidden = false
            
            chart.isHidden = false
            chartOpacitySlider.isHidden = false
            sceneViewOpacityView.isHidden = false
            openAngleChartButton.isHidden = false

            
            comparisonVideo1PointMarkTime = currentTimeMillis1
            comparisonVideo2PointMarkTime = currentTimeMillis2
            
            for i in 0..<selectedLandmarksCounter {
                if buttonStates[2] {
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].x)
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].x)
                } else if buttonStates[3] {
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].y)
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].y)
                } else if buttonStates[4]{
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].z)
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].z)
                }
            }
            updateChartView()
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            openChartButton.setImage(image, for: .normal)
            buttonStates[1] = false
            
            playerView.layer.opacity = 1
            landmarksView1.layer.opacity = 1
            landmarksView2.layer.opacity = 1
            sceneView1.layer.opacity = 1
            sceneView2.layer.opacity = 1
            
            if buttonStates[6] == false {
                selectLandmarksButton.isHidden = false
            }
            
            showPlayerButton.isHidden = false
            
            selectAxisButton.isHidden = true
            
            xAxisButton.isHidden = true
            yAxisButton.isHidden = true
            zAxisButton.isHidden = true
            
            chart.isHidden = true
            chartOpacitySlider.isHidden = true
            sceneViewOpacityView.isHidden = true

            openAngleChartButton.isHidden = true
            
        }
    }
    @objc func xAxisSelected() {
        xAxisButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.systemGreen.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        yAxisButton.setImage(UIImage(systemName: "y.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        zAxisButton.setImage(UIImage(systemName: "z.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .bold))?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal), for: .normal)
        buttonStates[2] = true
        buttonStates[3] = false
        buttonStates[4] = false
        
        comparisonVideo1PointMarkTime = currentTimeMillis1
        comparisonVideo2PointMarkTime = currentTimeMillis2
        
        for i in 0..<selectedLandmarksCounter {
            comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].x)
            comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].x)
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
        
        comparisonVideo1PointMarkTime = currentTimeMillis1
        comparisonVideo2PointMarkTime = currentTimeMillis2
        
        for i in 0..<selectedLandmarksCounter {
            comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].y)
            comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].y)
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
        
        comparisonVideo1PointMarkTime = currentTimeMillis1
        comparisonVideo2PointMarkTime = currentTimeMillis2
        
        for i in 0..<selectedLandmarksCounter {
            comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].z)
            comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].z)
        }
        
        updateSelectAxisButton()
        
        updateChartView()
    }
    
    @objc func showPlayer() {
        if buttonStates[6] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
            let image = UIImage(systemName: "video.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            showPlayerButton.setImage(image, for: .normal)
            buttonStates[6] = true
            sceneView1.isHidden = true
            sceneView2.isHidden = true
            playerView.isHidden = false
            landmarksView1.isHidden = false
            landmarksView2.isHidden = false
            selectLandmarksButton.isHidden = true
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 38, weight: .bold)
            let image = UIImage(systemName: "video.circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            showPlayerButton.setImage(image, for: .normal)
            buttonStates[6] = false
            playerView.isHidden = true
            sceneView1.isHidden = false
            sceneView2.isHidden = false
            landmarksView1.isHidden = true
            landmarksView2.isHidden = true
            selectLandmarksButton.isHidden = false
        }
    }
   
    @objc func connectSliders() {
        if buttonStates[7] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            let image = UIImage(systemName: "lock.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            connectSlidersButton.setImage(image, for: .normal)
            buttonStates[7] = true
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            let image = UIImage(systemName: "lock.open.fill", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            connectSlidersButton.setImage(image, for: .normal)
            buttonStates[7] = false
        }
    }
    
    @objc func opacitySliderValueChanged() {
        let value = chartOpacitySlider.value
        self.chart.alpha = CGFloat(value / 100)
        playerView.layer.opacity = 1 - (value / 100)
        landmarksView1.layer.opacity = 1 - (value / 100)
        landmarksView2.layer.opacity = 1 - (value / 100)
        sceneView1.layer.opacity = 1 - (value / 100)
        sceneView2.layer.opacity = 1 - (value / 100)
    }
    
    @objc func openAngleChart() {
        if buttonStates[5] == false {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(named: "angle.button.selected")
            openAngleChartButton.setImage(image, for: .normal)
            xAxisButton.isHidden = true
            yAxisButton.isHidden = true
            zAxisButton.isHidden = true
            //chart.isHidden = true
            openChartButton.isHidden = true
            selectAxisButton.isHidden = true
            
            buttonStates[5].toggle()
            
            for i in 0..<5 {
                comparisonAnglePointMarks1[i] = comparisonAngleDataList1[i][currentLandmarkIndex1].angles
                comparisonAnglePointMarks2[i] = comparisonAngleDataList2[i][currentLandmarkIndex2].angles
            }
            
            updateChartView()
        } else {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let image = UIImage(named: "angle.button")
            openAngleChartButton.setImage(image, for: .normal)
            
            //chart.isHidden = false
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if (player1.currentItem?.status == .readyToPlay) && (player2.currentItem?.status == .readyToPlay) {
                duration1 = CMTimeGetSeconds(player1.currentItem!.duration)
                duration2 = CMTimeGetSeconds(player2.currentItem!.duration)
                self.setTimeLables(time: CMTime.zero, player: 1)
                self.setTimeLables(time: CMTime.zero, player: 2)
                updateLandmarks1(for: CMTime.zero)
                updateLandmarks2(for: CMTime.zero)
                if !duration1!.isNaN && duration1! > 0 {
                    slider1.maximumValue = Float(duration1!)
                    slider1.addTarget(self, action: #selector(slider1ValueChanged), for: .valueChanged)
                }
                if !duration2!.isNaN && duration2! > 0 {
                    slider2.maximumValue = Float(duration2!)
                    slider2.addTarget(self, action: #selector(slider2ValueChanged), for: .valueChanged)
                }
            }
        }
    }
    
    func updateChartView() {
        if selectedLandmarksCounter == 0 {
            comparisonLandmarkDataList1 = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            comparisonLandmarkDataList2 = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
        } else {

            var coordinates1: [[Float]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            var coordinates2: [[Float]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            if buttonStates[2] == true {
                //x
                for i in 0..<selectedLandmarksCounter {
                    for subArray in video1Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates1[i].append(point.x)
                    }
                    for subArray in video2Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates2[i].append(point.x)
                    }
                }
            } else if buttonStates[3] == true {
                //y
                for i in 0..<selectedLandmarksCounter {
                    for subArray in video1Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates1[i].append(point.y)
                    }
                    for subArray in video2Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates2[i].append(point.y)
                    }
                }
            } else if buttonStates[4] == true {
                //z
                for i in 0..<selectedLandmarksCounter {
                    for subArray in video1Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates1[i].append(point.z)
                    }
                    for subArray in video2Landmarks3 {
                        let point = subArray[selectedLandmarkPoints[i]]
                        coordinates2[i].append(point.z)
                    }
                }
            }
            comparisonLandmarkDataList1 = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            comparisonLandmarkDataList2 = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
            
            for i in 0..<selectedLandmarksCounter {
                var timeIndex1 = 0
                var timeIndex2 = 0
                for point in coordinates1[i] {
                    comparisonLandmarkDataList1[i].append(chartComparisonLandmarkData1(landmarks: point, timestamps: video1Timestamps[timeIndex1]))
                    timeIndex1 = timeIndex1 + 1
                }
                for point in coordinates2[i] {
                    comparisonLandmarkDataList2[i].append(chartComparisonLandmarkData2(landmarks: point, timestamps: video2Timestamps[timeIndex2]))
                    timeIndex2 = timeIndex2 + 1
                }
            }
            
        }
        for view in self.chart.subviews {
            view.removeFromSuperview()
        }
        let controller = UIHostingController(rootView: ComparisonLandmarkChart())
        chartView = controller.view
        
        if buttonStates[5] {
            let angleController = UIHostingController(rootView: ComparisonAngleChart())
            chartView = angleController.view
        }
        
        chartView.frame = CGRect(x: 40, y: 20, width: Int(UIScreen.main.bounds.size.width) - 80, height: Int(UIScreen.main.bounds.size.height) - 80)
        chartView.backgroundColor = .clear
        chart.addSubview(chartView)
    }

    func updateLandmarks1(for time: CMTime) {
        currentTimeMillis1 = Int(CMTimeGetSeconds(time) * 1000)
        comparisonVideo1PointMarkTime = currentTimeMillis1
        if let index = video1Timestamps.firstIndex(where: { ($0 >= currentTimeMillis1) && ($0 < (currentTimeMillis1 + 100))}) {
            let pixelCoordinates = video1Landmarks![index]
            let pointCoordinates = convertPixelsToPoints(points: pixelCoordinates, angle: videoAngle1, width: videoWidth1!, height: videoHeight1!)
            scene1.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
            }
            addCoordinateSystem(toScene: scene1)
            addPoints(coordinates: video1Landmarks3[index], toScene: scene1, color: landmarkColors)
            currentLandmarkIndex1 = index
            
            for i in 0..<selectedLandmarksCounter {
                if buttonStates[2] {
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].x)
                } else if buttonStates[3] {
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].y)
                } else if buttonStates[4]{
                    comparisonVideo1PointMarks[i] = (video1Landmarks3[currentLandmarkIndex1][selectedLandmarkPoints[i]].z)
                }
            }
            
            for i in 0..<5 {
                comparisonAnglePointMarks1[i] = comparisonAngleDataList1[i][index].angles
            }
            
            if firstFrame1 == true {
                landmarks1 = []
                for point in pointCoordinates {
                    landmarks1.append(Landmark(point: point, color: .darkGray, selected: false))
                }
                landmarksView1.landmarks = landmarks1
                firstFrame1 = false
            } else {
                if landmarksView1.landmarks.isEmpty {
                    landmarksView1.landmarks = landmarkMemory1
                }
                var i = 0
                for point in pointCoordinates {
                    landmarks1[i] = Landmark(point: point, color: landmarksView1.landmarks[i].color, selected: landmarksView1.landmarks[i].selected)
                    i = i + 1
                }
                landmarksView1.landmarks = landmarks1
            }
            landmarksView1.setNeedsDisplay()
            
        } else {
            if landmarksView1.landmarks.isEmpty == false {
                landmarkMemory1 = landmarksView1.landmarks
            }
            landmarksView1.landmarks = []
            landmarksView1.setNeedsDisplay()
        }
    }
    func updateLandmarks2(for time: CMTime) {
        currentTimeMillis2 = Int(CMTimeGetSeconds(time) * 1000)
        comparisonVideo2PointMarkTime = currentTimeMillis2
        if let index = video2Timestamps.firstIndex(where: { ($0 >= currentTimeMillis2) && ($0 < (currentTimeMillis2 + 100))}) {
            let pixelCoordinates = video2Landmarks![index]
            let pointCoordinates = convertPixelsToPoints(points: pixelCoordinates, angle: videoAngle2, width: videoWidth2!, height: videoHeight2!)
            scene2.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
            }
            addCoordinateSystem(toScene: scene2)
            addPoints(coordinates: video2Landmarks3[index], toScene: scene2, color: landmarkColors)
            currentLandmarkIndex2 = index
            
            for i in 0..<selectedLandmarksCounter {
                if buttonStates[2] {
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].x)
                } else if buttonStates[3] {
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].y)
                } else if buttonStates[4]{
                    comparisonVideo2PointMarks[i] = (video2Landmarks3[currentLandmarkIndex2][selectedLandmarkPoints[i]].z)
                }
            }
            
            for i in 0..<5 {
                comparisonAnglePointMarks2[i] = comparisonAngleDataList2[i][index].angles
            }
            
            if firstFrame2 == true {
                landmarks2 = []
                for point in pointCoordinates {
                    landmarks2.append(Landmark(point: point, color: .darkGray, selected: false))
                }
                landmarksView2.landmarks = landmarks2
                firstFrame2 = false
            } else {
                if landmarksView2.landmarks.isEmpty {
                    landmarksView2.landmarks = landmarkMemory2
                }
                var i = 0
                for point in pointCoordinates {
                    landmarks2[i] = Landmark(point: point, color: landmarksView2.landmarks[i].color, selected: landmarksView2.landmarks[i].selected)
                    i = i + 1
                }
                landmarksView2.landmarks = landmarks2
            }
            landmarksView2.setNeedsDisplay()
            
        } else {
            if landmarksView2.landmarks.isEmpty == false {
                landmarkMemory2 = landmarksView2.landmarks
            }
            landmarksView2.landmarks = []
            landmarksView2.setNeedsDisplay()
        }
    }
    
    func addCoordinateSystem(toScene scene: SCNScene, length: Float = 10, radius: CGFloat = 0.3) {
        // X-Achse (rot)
        let xCylinder = SCNCylinder(radius: radius, height: CGFloat(length))
        xCylinder.firstMaterial?.diffuse.contents = UIColor.red
        let xNode = SCNNode(geometry: xCylinder)
        xNode.position = SCNVector3(length/2, 0, 0)
        xNode.eulerAngles.z = Float.pi / 2
        scene.rootNode.addChildNode(xNode)
        
        // Y-Achse (grün)
        let yCylinder = SCNCylinder(radius: radius, height: CGFloat(length))
        yCylinder.firstMaterial?.diffuse.contents = UIColor.green
        let yNode = SCNNode(geometry: yCylinder)
        yNode.position = SCNVector3(0, length/2, 0)
        scene.rootNode.addChildNode(yNode)
        
        // Z-Achse (blau)
        let zCylinder = SCNCylinder(radius: radius, height: CGFloat(length))
        zCylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let zNode = SCNNode(geometry: zCylinder)
        zNode.position = SCNVector3(0, 0, length/2)
        zNode.eulerAngles.x = Float.pi / 2
        scene.rootNode.addChildNode(zNode)
    }
    func addPoints(coordinates: [SCNVector3], toScene scene: SCNScene, color: [UIColor]) {
        for (index, coordinate) in coordinates.enumerated() {
            let sphere = SCNSphere(radius: 2.5)
            let material = SCNMaterial()
            material.diffuse.contents = color[index]
            sphere.materials = [material]
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = coordinate
            sphereNode.name = String(index)
            scene.rootNode.addChildNode(sphereNode)
        }
        connectPoints(coordinates: coordinates, toScene: scene, color: .gray)
    }
    func connectPoints(coordinates: [SCNVector3], toScene scene: SCNScene, color: UIColor) {
        var add = 0
        for _ in 0..<5 {
            var lineNode = lineFrom(vector: coordinates[0], toVector: coordinates[1+add], toScene: scene, color: color)
            scene.rootNode.addChildNode(lineNode)
            lineNode = lineFrom(vector: coordinates[1+add], toVector: coordinates[2+add], toScene: scene, color: color)
            scene.rootNode.addChildNode(lineNode)
            lineNode = lineFrom(vector: coordinates[2+add], toVector: coordinates[3+add], toScene: scene, color: color)
            scene.rootNode.addChildNode(lineNode)
            lineNode = lineFrom(vector: coordinates[3+add], toVector: coordinates[4+add], toScene: scene, color: color)
            scene.rootNode.addChildNode(lineNode)
            add = add + 4
        }
    }
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3,  toScene scene: SCNScene, color: UIColor) -> SCNNode {
        let distance = vector1.distance(to: vector2)
        let midPoint = vector1.midPoint(to: vector2)

        let cylinder = SCNCylinder(radius: 0.5, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = color

        let node = SCNNode()
        node.position = midPoint
        node.look(at: vector2, up: scene.rootNode.worldUp, localFront: SCNNode.localFront)

        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.eulerAngles.x = Float.pi / 2

        node.addChildNode(cylinderNode)

        return node
    }
    
    func calculateCameraSize(landmarks: [[SCNVector3]]) -> Float {
        let vectors = landmarks[0]
        guard !vectors.isEmpty else {
            return -150
        }
        var maxY = vectors.first!.y
        var minY = vectors.first!.y
        for vector in vectors {
            if vector.y > maxY {
                maxY = vector.y
            }
            if vector.y < minY {
                minY = vector.y
            }
        }
        let distance = (maxY - minY) * -1.5
        return distance
    }
    
    func setTimeLables(time: CMTime, player: Int) {
        let currentTime = CMTimeGetSeconds(time)
        let currentMinutes = Int(currentTime) / 60
        let currentSeconds = Int(currentTime) % 60
        if player == 1 {
            currentLabel1.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
            var remainingTime = 0
            if duration1 != nil {
                remainingTime = Int((duration1!) - currentTime)
            }
            let remainingMinutes = Int(remainingTime) / 60
            var remainingSeconds = remainingTime
            if remainingTime >= 60 {
                remainingSeconds = Int(remainingTime) % 60
            }
            remainingLabel1.text = "-" + String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        } else if player == 2 {
            currentLabel2.text = String(format: "%02d:%02d", currentMinutes, currentSeconds)
            var remainingTime = 0
            if duration2 != nil {
                remainingTime = Int((duration2!) - currentTime)
            }
            let remainingMinutes = Int(remainingTime) / 60
            var remainingSeconds = remainingTime
            if remainingTime >= 60 {
                remainingSeconds = Int(remainingTime) % 60
            }
            remainingLabel2.text = "-" + String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        }
    }
    
    func calculateAngles() {
        for (index, landmark) in video1Landmarks3.enumerated() {
            let angle1: Float = Float(angleBetweenVectors1(landmark[0], landmark[1], landmark[2]))
            let angle2: Float = Float(angleBetweenVectors1(landmark[0], landmark[5], landmark[6]))
            let angle3: Float = Float(angleBetweenVectors1(landmark[0], landmark[9], landmark[10]))
            let angle4: Float = Float(angleBetweenVectors1(landmark[0], landmark[13], landmark[14]))
            let angle5: Float = Float(angleBetweenVectors1(landmark[0], landmark[17], landmark[18]))
                
            comparisonAngleDataList1[0].append(chartAngleData(angles: angle1, timestamps: video1Timestamps[index]))
            comparisonAngleDataList1[1].append(chartAngleData(angles: angle2, timestamps: video1Timestamps[index]))
            comparisonAngleDataList1[2].append(chartAngleData(angles: angle3, timestamps: video1Timestamps[index]))
            comparisonAngleDataList1[3].append(chartAngleData(angles: angle4, timestamps: video1Timestamps[index]))
            comparisonAngleDataList1[4].append(chartAngleData(angles: angle5, timestamps: video1Timestamps[index]))
        }
        for (index, landmark) in video2Landmarks3.enumerated() {
            let angle1: Float = Float(angleBetweenVectors1(landmark[0], landmark[1], landmark[2]))
            let angle2: Float = Float(angleBetweenVectors1(landmark[0], landmark[5], landmark[6]))
            let angle3: Float = Float(angleBetweenVectors1(landmark[0], landmark[9], landmark[10]))
            let angle4: Float = Float(angleBetweenVectors1(landmark[0], landmark[13], landmark[14]))
            let angle5: Float = Float(angleBetweenVectors1(landmark[0], landmark[17], landmark[18]))

            comparisonAngleDataList2[0].append(chartAngleData(angles: angle1, timestamps: video2Timestamps[index]))
            comparisonAngleDataList2[1].append(chartAngleData(angles: angle2, timestamps: video2Timestamps[index]))
            comparisonAngleDataList2[2].append(chartAngleData(angles: angle3, timestamps: video2Timestamps[index]))
            comparisonAngleDataList2[3].append(chartAngleData(angles: angle4, timestamps: video2Timestamps[index]))
            comparisonAngleDataList2[4].append(chartAngleData(angles: angle5, timestamps: video2Timestamps[index]))
        }

    }
    
    func setLandmarkFrames() {
        let asset1 = AVAsset(url: video1URL!)
        let asset2 = AVAsset(url: video2URL!)
        let videoTrack1 = asset1.tracks(withMediaType: AVMediaType.video).first!
        let videoTrack2 = asset2.tracks(withMediaType: AVMediaType.video).first!
        let naturalSize1 = videoTrack1.naturalSize
        let naturalSize2 = videoTrack2.naturalSize
        let videoOrientation1 = videoTrack1.preferredTransform
        let videoOrientation2 = videoTrack2.preferredTransform
        let videoAngle1 = atan2(videoOrientation1.b, videoOrientation1.a) * (180 / .pi)
        let videoAngle2 = atan2(videoOrientation2.b, videoOrientation2.a) * (180 / .pi)
        
        if abs(videoAngle1) == 90 {
            // Hochformat
            let factor = naturalSize1.width / 375
            let videoWidth = Int(naturalSize1.height / factor) / 2
            let videoHeight = Int(naturalSize1.width / factor) / 2
            landmarkFrame1 = CGRect(x: ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        } else if abs(videoAngle1) == 0 {
            // Querformat 1
            let factor = naturalSize1.height / 375
            let videoWidth = Int(naturalSize1.width / factor) / 2
            let videoHeight = Int(naturalSize1.height / factor) / 2
            landmarkFrame1 = CGRect(x: ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        } else if abs(videoAngle1) == 180 {
            // Querformat 2
            let factor = naturalSize1.height / 375
            let videoWidth = Int(naturalSize1.width / factor) / 2
            let videoHeight = Int(naturalSize1.height / factor) / 2
            landmarkFrame1 = CGRect(x: ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        }
        
        if abs(videoAngle2) == 90 {
            // Hochformat
            let factor = naturalSize1.width / 375
            let videoWidth = Int(naturalSize1.height / factor) / 2
            let videoHeight = Int(naturalSize1.width / factor) / 2
            landmarkFrame2 = CGRect(x: Int(UIScreen.main.bounds.size.height / 2) + ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        } else if abs(videoAngle2) == 0 {
            // Querformat 1
            let factor = naturalSize1.height / 375
            let videoWidth = Int(naturalSize1.width / factor) / 2
            let videoHeight = Int(naturalSize1.height / factor) / 2
            landmarkFrame2 = CGRect(x: Int(UIScreen.main.bounds.size.height / 2) + ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        } else if abs(videoAngle2) == 180 {
            // Querformat 2
            let factor = naturalSize1.height / 375
            let videoWidth = Int(naturalSize1.width / factor) / 2
            let videoHeight = Int(naturalSize1.height / factor) / 2
            landmarkFrame2 = CGRect(x: Int(UIScreen.main.bounds.size.height / 2) + ((Int(UIScreen.main.bounds.size.height / 2) - videoWidth) / 2), y: 0, width: videoWidth, height: videoHeight)
        }
    }
    
    func calculateVideoFrame(in view: CGRect, videoURL: URL, videoN: Int) -> CGRect {
        let asset = AVAsset(url: videoURL)
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("Kein Video-Track verfügbar")
            return .zero
        }
        let videoSize = track.naturalSize
        
        let videoOrientation = track.preferredTransform
        let videoAngle = atan2(videoOrientation.b, videoOrientation.a) * (180 / .pi)
        var videoAspectRatio = videoSize.width / videoSize.height
        
        let factor = videoSize.width / 375
        var videoWidth = Int()
        var videoHeight = Int()
        if abs(videoAngle) == 90 {
            videoAspectRatio = videoSize.height / videoSize.width
            videoWidth = Int(videoSize.height / factor)
            videoHeight = Int(videoSize.width / factor)
        } else {
            videoWidth = Int(videoSize.width / factor)
            videoHeight = Int(videoSize.height / factor)
        }
         
        let viewSize = view.size
        let viewAspectRatio = viewSize.width / viewSize.height

        var addToX = 0
        
        if videoN == 2 {
            addToX = (Int(UIScreen.main.bounds.size.height) / 2)
            videoAngle2 = videoAngle
            videoWidth2 = videoWidth
            videoHeight2 = videoHeight
        } else {
            videoAngle1 = videoAngle
            videoWidth1 = videoWidth
            videoHeight1 = videoHeight
        }
        if videoAspectRatio > viewAspectRatio {
            // Video ist breiter als der View
            let scaledHeight = viewSize.width / videoAspectRatio
            let yOffset = (viewSize.height - scaledHeight) / 2
            return CGRect(x: CGFloat(addToX), y: yOffset, width: viewSize.width, height: scaledHeight)
        } else {
            // Video ist höher als der View
            let scaledWidth = viewSize.height * videoAspectRatio
            let xOffset = (viewSize.width - scaledWidth) / 2
            return CGRect(x: xOffset + CGFloat(addToX), y: 0, width: scaledWidth, height: viewSize.height)
        }
    }

    func convertPixelsToPoints(points: [CGPoint], angle: CGFloat, width: Int, height: Int) -> [CGPoint] {
        if  angle == 90 {
            let scale = (UIScreen.main.scale) / (CGFloat(width) / CGFloat(height)) * 0.95
            return points.map { CGPoint(x: $0.x / scale, y: $0.y / scale) }
        } else if angle == 180 {
            let scale = (UIScreen.main.scale) / (CGFloat(height) / CGFloat(width)) * 0.95
            
            return points.map { CGPoint(x: (390.5 - ($0.y / scale)), y: ($0.x / scale) ) }
        } else {
            let scale = (UIScreen.main.scale) / (CGFloat(height) / CGFloat(width)) * 0.95
            let minus = CGFloat(378 - Float(height))
            return points.map { CGPoint(x: ($0.y / scale), y: (395 - ($0.x / scale)) - (minus)) }
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
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
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
    }
}
