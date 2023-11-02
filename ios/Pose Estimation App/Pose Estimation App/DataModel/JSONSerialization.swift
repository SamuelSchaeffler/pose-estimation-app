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
                
                let landmarks = landmarksAny.map { $0.compactMap { dict in
                    if let x = dict["x"] as? Float,
                       let y = dict["y"] as? Float,
                       let z = dict["z"] as? Float {
                        return SCNVector3(x, y, z)
                    }
                    return nil
                }}
                
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


