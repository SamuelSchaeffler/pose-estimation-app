//
//  HandLandmarker.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 16.10.23.
//

import MediaPipeTasksVision
import SceneKit

class MediaPipeHandLandmarker {
    
    private var handLandmarker: HandLandmarker?
    private var options: HandLandmarkerOptions
    
    var uiImage: UIImage?
    var result: HandLandmarkerResult?
    
    init() {
        options = HandLandmarkerOptions()
        options.runningMode = .image
        options.numHands = 2
        options.minHandDetectionConfidence = 0.5
        options.minHandPresenceConfidence = 0.5
        options.minTrackingConfidence = 0.5
            
        if let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") {
            options.baseOptions.modelAssetPath = modelPath
        }
            
        do {
            handLandmarker = try HandLandmarker(options: options)
        } catch {
            print(error)
        }
    }
    
    func detectHands(image: UIImage) -> HandLandmarkerResult? {
        uiImage = image
        let mpImage = try! MPImage(uiImage: image)
        do {
            result = try handLandmarker?.detect(image: mpImage)
            print()
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    func drawBoundingBoxes() -> UIImage? {
        var index = -1
        let image = uiImage!
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
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func drawLandmarks() -> UIImage? {
        var index = -1
        let image = uiImage!
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
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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
}
