//
//  PhotoComparisonViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 09.10.23.
//

import UIKit
import SceneKit
import MediaPipeTasksVision

class PhotoComparisonViewController: UIViewController {

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
    
    var images: [UIImage] = []
    var mpImages: [MPImage] = []
    var results: [HandLandmarkerResult] = []
    var colors: [UIColor] = [.red, .blue, .green, .yellow, .purple]
    
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
    
    let imageView1: UIImageView = {
        var view = UIImageView()
        view.frame = CGRect(x: 100, y: 200, width: 200, height: 200)
        return view
    }()
    let imageView2: UIImageView = {
        var view = UIImageView()
        view.frame = CGRect(x: 100, y: 500, width: 200, height: 200)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
                
        do {
            handLandmarker = try HandLandmarker(options: handLandmarkerOptions)
            print("Tracker initialisiert!")
        } catch {
            print(error)
        }

        let sceneView = SCNView(frame: self.view.bounds)
        sceneView.backgroundColor = UIColor.white
            
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
            
        for i in 0..<(images.count) {
            mpImages.append(try! MPImage(uiImage: images[i]))
            results.append(try! handLandmarker!.detect(image: mpImages[i]))
            if results[i].landmarks.isEmpty == false {
                addPoints(coordinates: getWorldLandmarks(result: results[i], image: images[i]), toScene: scene, color: colors[i])
            }
        }
        
        view.addSubview(sceneView)
        view.addSubview(closeButton)
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
    
    func getLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
        let imageSize = image.size
        let coordinates = result.landmarks[0]
        var points: [SCNVector3] = []
        if imageSize.height > imageSize.width {
            for i in 0..<21 {
                let xPoint = imageSize.width - (CGFloat(coordinates[i].y) * imageSize.width)
                let yPoint = CGFloat(coordinates[i].x) * imageSize.height
                let zPoint = CGFloat(coordinates[i].z) * imageSize.width
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        } else {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].x) * imageSize.width
                let yPoint = CGFloat(coordinates[i].y) * imageSize.height
                let zPoint = CGFloat(coordinates[i].z) * imageSize.width
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        }
        return points
    }
    
    func getWorldLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
        let imageSize = image.size
        let coordinates = result.worldLandmarks[0]
        var points: [SCNVector3] = []
        if imageSize.height > imageSize.width {
            for i in 0..<21 {
                let xPoint = 7000 - CGFloat(coordinates[i].y) * 7000
                let yPoint = CGFloat(coordinates[i].x) * 7000
                let zPoint = CGFloat(coordinates[i].z) * 7000
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        } else {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].x) * 7000
                let yPoint = CGFloat(coordinates[i].y) * 7000
                let zPoint = CGFloat(coordinates[i].z) * 7000
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        }
        return points
    }
    
    func addPoints(coordinates: [SCNVector3], toScene scene: SCNScene, color: UIColor) {
        let shiftedCoordinates = shiftCoordinates(coordinates: coordinates)
        for coordinate in shiftedCoordinates {
            let sphere = SCNSphere(radius: 15)
            let material = SCNMaterial()
            material.diffuse.contents = color
            sphere.materials = [material]
            let node = SCNNode(geometry: sphere)
            node.position = coordinate
            scene.rootNode.addChildNode(node)
        }
        connectPoints(coordinates: shiftedCoordinates, toScene: scene, color: color)
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

        let cylinder = SCNCylinder(radius: 5, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = color

        let node = SCNNode()
        node.position = midPoint
        node.look(at: vector2, up: scene.rootNode.worldUp, localFront: SCNNode.localFront)

        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.eulerAngles.x = Float.pi / 2

        node.addChildNode(cylinderNode)

        return node
    }
    
    func shiftCoordinates(coordinates: [SCNVector3]) -> [SCNVector3] {
        guard let firstCoordinate = coordinates.first else { return coordinates }
        let shiftVector = SCNVector3(-firstCoordinate.x, -firstCoordinate.y, -firstCoordinate.z)
        var shiftedCoordinates = [SCNVector3]()
        for coordinate in coordinates {
            let shiftedCoordinate = SCNVector3(coordinate.x + shiftVector.x, coordinate.y + shiftVector.y, coordinate.z + shiftVector.z)
            shiftedCoordinates.append(shiftedCoordinate)
        }
        return shiftedCoordinates
    }

}

extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        let dx = vector.x - x
        let dy = vector.y - y
        let dz = vector.z - z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    func midPoint(to vector: SCNVector3) -> SCNVector3 {
        return SCNVector3((vector.x + x) / 2, (vector.y + y) / 2, (vector.z + z) / 2)
    }
}
