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

    var images: [UIImage] = []
    var results: [HandLandmarkerResult] = []
    var colors: [UIColor] = [.red, .blue, .green, .yellow, .purple]
    let handLandmarker = MediaPipeHandLandmarker()
    
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

    let handAngleText: UILabel = {
        var text = UILabel()
        text.textColor = .label
        text.textAlignment = .center
        text.frame = CGRect(x: 50, y: Int(UIScreen.main.bounds.size.height) - 50, width: Int(UIScreen.main.bounds.size.width) - 100, height: 25)
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        let sceneView = SCNView(frame: self.view.bounds)
        sceneView.backgroundColor = UIColor.systemBackground
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.pointOfView?.camera?.automaticallyAdjustsZRange = true
            
        addCoordinateSystem(toScene: scene)
        
        for i in 0..<(images.count) {
            results.append(handLandmarker.detectHands(image: images[i])!)
            if results[i].landmarks.isEmpty == false {
                let coordinates = handLandmarker.getWorldLandmarks(result: results[i], image: images[i])
                let transformedCoordinates = transform(coordinates: coordinates)
                addPoints(coordinates: transformedCoordinates, toScene: scene, color: colors[i])
            }
        }
        
        if images.count == 2 {
            calculateHandAngle(scene: scene)
        }
        
        view.addSubview(sceneView)
        view.addSubview(closeButton)
        view.addSubview(handAngleText)
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
    
    func addCoordinateSystem(toScene scene: SCNScene, length: Float = 100) {
        // X-Achse (rot)
        let xCylinder = SCNCylinder(radius: 3, height: CGFloat(length))
        xCylinder.firstMaterial?.diffuse.contents = UIColor.red
        let xNode = SCNNode(geometry: xCylinder)
        xNode.position = SCNVector3(length/2, 0, 0)
        xNode.eulerAngles.z = Float.pi / 2
        scene.rootNode.addChildNode(xNode)
        // Y-Achse (grün)
        let yCylinder = SCNCylinder(radius: 3, height: CGFloat(length))
        yCylinder.firstMaterial?.diffuse.contents = UIColor.green
        let yNode = SCNNode(geometry: yCylinder)
        yNode.position = SCNVector3(0, length/2, 0)
        scene.rootNode.addChildNode(yNode)
        // Z-Achse (blau)
        let zCylinder = SCNCylinder(radius: 3, height: CGFloat(length))
        zCylinder.firstMaterial?.diffuse.contents = UIColor.blue
        let zNode = SCNNode(geometry: zCylinder)
        zNode.position = SCNVector3(0, 0, length/2)
        zNode.eulerAngles.x = Float.pi / 2
        scene.rootNode.addChildNode(zNode)
    }
    
    func addPoints(coordinates: [SCNVector3], toScene scene: SCNScene, color: UIColor) {
        for coordinate in coordinates {
            let sphere = SCNSphere(radius: 15)
            let material = SCNMaterial()
            material.diffuse.contents = color
            sphere.materials = [material]
            let node = SCNNode(geometry: sphere)
            node.position = coordinate
            scene.rootNode.addChildNode(node)
        }
        connectPoints(coordinates: coordinates, toScene: scene, color: color)
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

    func transform(coordinates: [SCNVector3]) -> [SCNVector3] {
        let point1 = coordinates[0]
        let point2 = coordinates[9]
        let translationMatrix = SCNMatrix4MakeTranslation(-point1.x, -point1.y, -point1.z)
        let direction = SCNVector3(x: point2.x - point1.x, y: point2.y - point1.y, z: point2.z - point1.z)
        let rotationAxis = direction.cross(SCNVector3(x: -1, y: 0, z: 0))
        let angle = acos(direction.dot(SCNVector3(x: -1, y: 0, z: 0)) / direction.length())
        print(angle * (180 / .pi))
        let rotationMatrix1 = SCNMatrix4MakeRotation(angle, rotationAxis.x, rotationAxis.y, rotationAxis.z)
        print(rotationMatrix1)
        let rotationMatrix2 = SCNMatrix4MakeRotation( .pi, 1, 0, 0)
        var transformedCoordinates = [SCNVector3]()
        for coordinate in coordinates {
            var vector = coordinate
            vector = vector.applying(translationMatrix)
            vector = vector.applying(rotationMatrix1)
            if (angle * (180 / .pi)) >= 180 {
                vector = vector.applying(rotationMatrix2)
            }
            transformedCoordinates.append(vector)
        }
        return transformedCoordinates
    }
    
    func transformNew(coordinates: [SCNVector3]) -> [SCNVector3] {
        let shiftedCoordinates = shiftCoordinates(coordinates: coordinates)
        let point1 = shiftedCoordinates[0]
        let point2 = shiftedCoordinates[9]
        let direction = SCNVector3(x: point2.x - point1.x, y: point2.y - point1.y, z: point2.z - point1.z)
        let rotationAxis = direction.cross(SCNVector3(x: 1, y: 0, z: 0))
        let angle = acos(direction.dot(SCNVector3(x: 1, y: 0, z: 0)) / direction.length())
        let rotationMatrix = SCNMatrix4MakeRotation(angle, rotationAxis.x, rotationAxis.y, rotationAxis.z)
        var transformedCoordinates = [SCNVector3]()
        for coordinate in shiftedCoordinates {
            var vector = coordinate
            transformedCoordinates.append(vector)
        }
        return transformedCoordinates
    }
    
    func calculateHandAngle(scene: SCNScene) {
        let handCoordinates1 = transform(coordinates: (handLandmarker.getWorldLandmarks(result: results[0], image: images[0])))
        let handCoordinates2 = transform(coordinates: (handLandmarker.getWorldLandmarks(result: results[1], image: images[1])))
        let handVector1 = SCNVector3(handCoordinates1[17].x - handCoordinates1[5].x, handCoordinates1[17].y - handCoordinates1[5].y, handCoordinates1[17].z - handCoordinates1[5].z)
        let handVector2 = SCNVector3(handCoordinates2[17].x - handCoordinates2[5].x, handCoordinates2[17].y - handCoordinates2[5].y, handCoordinates2[17].z - handCoordinates2[5].z)
        let skalarProdukt = handVector1.dot(handVector2)
        let laenge1 = handVector1.length()
        let laenge2 = handVector2.length()
        let winkelInRadians = acos(skalarProdukt / (laenge1 * laenge2))
        let winkelInGrad = winkelInRadians * 180.0 / .pi
        handAngleText.text = ("Verdrehungswinkel: \(round(winkelInGrad))°")
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
    
    func applying(_ transform: SCNMatrix4) -> SCNVector3 {
        let x = transform.m11 * self.x + transform.m21 * self.y + transform.m31 * self.z + transform.m41
        let y = transform.m12 * self.x + transform.m22 * self.y + transform.m32 * self.z + transform.m42
        let z = transform.m13 * self.x + transform.m23 * self.y + transform.m33 * self.z + transform.m43
        return SCNVector3(x: x, y: y, z: z)
    }
    
    func cross(_ vector: SCNVector3) -> SCNVector3 {
        let x = self.y * vector.z - self.z * vector.y
        let y = self.z * vector.x - self.x * vector.z
        let z = self.x * vector.y - self.y * vector.x
        return SCNVector3(x: x, y: y, z: z)
    }
    
    func dot(_ vector: SCNVector3) -> Float {
        return self.x * vector.x + self.y * vector.y + self.z * vector.z
    }
    
    func length() -> Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
}
