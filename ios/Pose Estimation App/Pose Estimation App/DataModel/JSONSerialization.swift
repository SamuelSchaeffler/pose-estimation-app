//
//  JSONSerialization.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 31.10.23.
//

import SceneKit
import Foundation

func vector3ToDict(_ vector: SCNVector3) -> [String: Float] {
    return ["x": vector.x, "y": vector.y, "z": vector.z]
}

func dictToVector3(_ dict: [String: Float]) -> SCNVector3? {
    guard let x = dict["x"], let y = dict["y"], let z = dict["z"] else {
        return nil
    }
    return SCNVector3(x, y, z)
}

class videoLandmarksJSON {
    var landmarks: [[SCNVector3]]?
    var timestamps: [Int]?
}

func videoLandmarksToString(landmarks: [[SCNVector3]], worldLandmarks: [[SCNVector3]], timestamps: [Int]) -> String? {
    let landmarksDicts = landmarks.map { $0.map(vector3ToDict) }
    let worldLandmarksDicts = worldLandmarks.map { $0.map(vector3ToDict) }
    
    let object: [String: Any] = ["landmarks": landmarksDicts as Any, "worldLandmarks": worldLandmarksDicts as Any, "timestamps": timestamps as Any]
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    print("fehler beim schreiben des JSON-Strings!")
    return nil
}

func stringToVideoLandmarks(_ jsonString: String) -> ([[SCNVector3]], [[SCNVector3]], [Int])? {
    do {
        if let jsonData = jsonString.data(using: .utf8) {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            if let landmarksAny = jsonObject?["landmarks"] as? [[[String: AnyObject]]],
               let worldLandmarksAny = jsonObject?["worldLandmarks"] as? [[[String: AnyObject]]],
               let timestampsAny = jsonObject?["timestamps"] as? [Int] {
                
                let landmarks = landmarksAny.map { landmarkArray in
                    return landmarkArray.compactMap { landmarkDict in
                        if let x = landmarkDict["x"] as? Float ?? landmarkDict["y"] as? Float ?? landmarkDict["z"] as? Float,
                           let y = landmarkDict["y"] as? Float ?? landmarkDict["x"] as? Float ?? landmarkDict["z"] as? Float,
                           let z = landmarkDict["z"] as? Float ?? landmarkDict["x"] as? Float ?? landmarkDict["y"] as? Float {
                            return SCNVector3(x, y, z)
                        } else {
                            // Handle the case where a landmark dictionary is missing required values
                            print("Ungültiger Landmarkeintrag: \(landmarkDict)")
                            return nil
                        }
                    }
                }
                let worldLandmarks = worldLandmarksAny.map { worldLandmarkArray in
                    return worldLandmarkArray.compactMap { worldLandmarkDict in
                        if let x = worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["y"] as? Float ?? worldLandmarkDict["z"] as? Float,
                           let y = worldLandmarkDict["y"] as? Float ?? worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["z"] as? Float,
                           let z = worldLandmarkDict["z"] as? Float ?? worldLandmarkDict["x"] as? Float ?? worldLandmarkDict["y"] as? Float {
                            return SCNVector3(x, y, z)
                        } else {
                            // Handle the case where a landmark dictionary is missing required values
                            print("Ungültiger World Landmarkeintrag: \(worldLandmarkDict)")
                            return nil
                        }
                    }
                }

                //print(landmarksAny)
                return (landmarks, worldLandmarks, timestampsAny)
            } else {
                print("Fehler bei der Typumwandlung!")
            }
        }
    } catch let error {
        print("Fehler beim Lesen des JSON-Strings: \(error)")
    }
    
    return nil
}


func scnVector3ArrayToCGPointArray(_ vectors: [[SCNVector3]]) -> [[CGPoint]] {
    return vectors.map { innerArray in
        innerArray.map { vector in
            CGPoint(x: CGFloat(vector.x), y: CGFloat(vector.y))
        }
    }
}

func addVector(_ vector1: SCNVector3, _ vector2: SCNVector3) -> SCNVector3 {
    return SCNVector3(vector1.x + vector2.x, vector1.y + vector2.y, vector1.z + vector2.z)
}
func movingAverage(for landmarks: [[SCNVector3]], windowSize: Int) -> [[SCNVector3]] {
    var smoothedLandmarks = [[SCNVector3]]()

    for i in 0..<landmarks.count {
        var smoothedFrame = [SCNVector3]()
        for j in 0..<landmarks[i].count {
            var sum = SCNVector3(0, 0, 0)
            var count = 0
            for k in max(0, i - windowSize / 2)...min(landmarks.count - 1, i + windowSize / 2) {
                sum = addVector(sum, landmarks[k][j])
                count += 1
            }
            smoothedFrame.append(SCNVector3(sum.x / Float(count), sum.y / Float(count), sum.z / Float(count)))
        }
        smoothedLandmarks.append(smoothedFrame)
    }

    return smoothedLandmarks
}
func lowPassFilter(for landmarks: [[SCNVector3]], alpha: Float) -> [[SCNVector3]] {
    guard !landmarks.isEmpty else { return [] }
    
    var filteredLandmarks = [landmarks[0]] // Start with the first set of landmarks

    for i in 1..<landmarks.count {
        var filteredFrame = [SCNVector3]()
        for j in 0..<landmarks[i].count {
            let previousFilteredValue = filteredLandmarks[i-1][j]
            let currentValue = landmarks[i][j]
            let filteredValue = SCNVector3(
                alpha * currentValue.x + (1 - alpha) * previousFilteredValue.x,
                alpha * currentValue.y + (1 - alpha) * previousFilteredValue.y,
                alpha * currentValue.z + (1 - alpha) * previousFilteredValue.z
            )
            filteredFrame.append(filteredValue)
        }
        filteredLandmarks.append(filteredFrame)
    }

    return filteredLandmarks
}

