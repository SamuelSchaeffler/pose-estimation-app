//
//  HandLandmarker.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 16.10.23.
//

import CoreData
import MediaPipeTasksVision
import SceneKit
import AVFoundation

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
                rectColor = UIColor.systemRed
            } else {
                rectColor = UIColor.systemBlue
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
                pointColor = UIColor.systemRed
            } else {
                pointColor = UIColor.systemBlue
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
        let factor: CGFloat = 7000
        if imageSize.height > imageSize.width {
            for i in 0..<21 {
                let xPoint = factor - CGFloat(coordinates[i].y) * factor
                let yPoint = CGFloat(coordinates[i].x) * factor
                let zPoint = CGFloat(coordinates[i].z) * factor
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        } else {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].x) * factor
                let yPoint = CGFloat(coordinates[i].y) * factor
                let zPoint = CGFloat(coordinates[i].z) * factor
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        }
        return points
    }
}

class MediaPipeHandLandmarkerVideo {
    
    var mediaModel = MediaModel()
    private var handLandmarker: HandLandmarker?
    private var options: HandLandmarkerOptions
    var videoURL: URL?
    var result: HandLandmarkerResult?
    var tempTimestamp: Int = 0
    var videoLandmarks: [[SCNVector3]] = []
    var videoWorldLandmarks: [[SCNVector3]] = []
    var videoTimestamps: [Int] = []
    var videoAngle: CGFloat = 0
    let vectorFunctions = VectorFunctions()
    
    init() {
        options = HandLandmarkerOptions()
        options.runningMode = .video
        options.numHands = 1
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
    
    func generateLandmarks(objectID: NSManagedObjectID) {
        let videoURL = URL(string: mediaModel.getVideoURL(objectID: objectID)[0])
        autoreleasepool {
            let asset = AVAsset(url: videoURL!)
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                print("Fehler beim Abrufen des Video-Tracks")
                return
            }
            let naturalSize = videoTrack.naturalSize
            let transform = videoTrack.preferredTransform
            videoAngle = atan2(transform.b, transform.a) * (180 / .pi)
            let duration = CMTimeGetSeconds(asset.duration) * 1000
            guard let reader = try? AVAssetReader(asset: asset) else {
                print("Fehler beim Erstellen des AVAssetReaders")
                return
            }
            let readerOutputSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            ]
            let readerOutput = AVAssetReaderTrackOutput(track: asset.tracks(withMediaType: .video)[0], outputSettings: readerOutputSettings)
            reader.add(readerOutput)
            reader.startReading()
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264.rawValue,
                AVVideoWidthKey: naturalSize.width,
                AVVideoHeightKey: naturalSize.height
            ]
            let context = CIContext()
            while reader.status == .reading {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    autoreleasepool {
                        var timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        let orginalImage = self.convertSampleBufferToUIImage(sampleBuffer, context: context)
                        let progress = Float((CMTimeGetSeconds(timestamp) * 1000) / duration)
                        NotificationCenter.default.post(name: Notification.Name("updateProgress"), object: progress)
                        processFrameWithMediaPipe(orginalImage: orginalImage!, image: orginalImage!, timestamp: timestamp)
                    }
                } else {
                    reader.cancelReading()
                    NotificationCenter.default.post(name: Notification.Name("updateProgress"), object: 0)
                    let videoLandmarksString = vectorFunctions.videoLandmarksToString(landmarks: videoLandmarks, worldLandmarks: videoWorldLandmarks, timestamps: videoTimestamps)
                    mediaModel.saveVideoLandmarks(objectID: objectID, data: videoLandmarksString!)
                    videoLandmarks = []
                    videoWorldLandmarks = []
                    videoTimestamps = []
                    break
                }
            }
        }
    }
    
    func convertSampleBufferToUIImage(_ sampleBuffer: CMSampleBuffer, context: CIContext) -> UIImage? {
        autoreleasepool {
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
            let uiImage = (UIImage(cgImage: cgImage!))
            return uiImage
        }
    }
    
    func processFrameWithMediaPipe(orginalImage: UIImage, image: UIImage, timestamp: CMTime) {
        let mpImage = try! MPImage(uiImage: image)
        var timestampInMilliseconds = Int(CMTimeGetSeconds(timestamp) * 1000)
        if timestampInMilliseconds == tempTimestamp {
            timestampInMilliseconds += 1
        }
        tempTimestamp = timestampInMilliseconds
        let result = try! self.handLandmarker?.detect(videoFrame: mpImage, timestampInMilliseconds: timestampInMilliseconds)
        if result!.worldLandmarks.count > 0 {
            let landmarks = getLandmarks(result: result!, image: image)
            let worldLandmarks = getWorldLandmarks(result: result!, image: image)
            videoLandmarks.append(landmarks)
            videoWorldLandmarks.append(worldLandmarks)
            videoTimestamps.append(timestampInMilliseconds)
        }
    }
    
    func getWorldLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
        let imageSize = image.size
        let coordinates = result.worldLandmarks[0]
        var points: [SCNVector3] = []
        let factor = CGFloat(1000)
        if videoAngle == 90 {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].y) * factor * (-1)
                let yPoint = CGFloat(coordinates[i].x) * factor
                let zPoint = CGFloat(coordinates[i].z) * factor
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        } else if videoAngle == 180 {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].x) * factor * (-1)
                let yPoint = CGFloat(coordinates[i].y) * factor * (-1)
                let zPoint = CGFloat(coordinates[i].z) * factor
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        } else {
            for i in 0..<21 {
                let xPoint = CGFloat(coordinates[i].x) * factor
                let yPoint = CGFloat(coordinates[i].y) * factor
                let zPoint = CGFloat(coordinates[i].z) * factor
                points.append(SCNVector3(x: Float(xPoint), y: Float(yPoint), z: Float(zPoint)))
            }
        }
        return points
    }
    
    func getLandmarks(result: HandLandmarkerResult, image: UIImage) -> [SCNVector3] {
        var imageSize = image.size
        let targetSize = CGSize(width: 1920, height: 1080)
        let widthRatio  = targetSize.width  / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: imageSize.width * heightRatio, height: imageSize.height * heightRatio)
        } else {
            newSize = CGSize(width: imageSize.width * widthRatio,  height: imageSize.height * widthRatio)
        }
        imageSize = newSize
        let coordinates = result.landmarks[0]
        var points: [SCNVector3] = []
        if imageSize.height < imageSize.width {
            for i in 0..<21 {
                let xPoint = imageSize.height - CGFloat(coordinates[i].y) * imageSize.height
                let yPoint = CGFloat(coordinates[i].x) * imageSize.width
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
}
