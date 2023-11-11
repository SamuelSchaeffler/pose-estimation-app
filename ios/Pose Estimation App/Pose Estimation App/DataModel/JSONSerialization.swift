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

func videoLandmarksToString(landmarks: [[SCNVector3]], timestamps: [Int]) -> String? {
    let landmarksDicts = landmarks.map { $0.map(vector3ToDict) }
    
    let object: [String: Any] = ["landmarks": landmarksDicts as Any, "timestamps": timestamps as Any]
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    print("fehler beim schreiben des JSON-Strings!")
    return nil
}

func stringToVideoLandmarks(_ jsonString: String) -> ([[SCNVector3]], [Int])? {
    do {
        if let jsonData = jsonString.data(using: .utf8) {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            if let landmarksAny = jsonObject?["landmarks"] as? [[[String: AnyObject]]],
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

                return (landmarks, timestampsAny)
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
