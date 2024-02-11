//
//  VectorFunctions.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 31.10.23.
//

import SceneKit

class VectorFunctions {
    
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
                                print("Ungültiger World Landmarkeintrag: \(worldLandmarkDict)")
                                return nil
                            }
                        }
                    }
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

    func angleBetweenVectors(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> CGFloat {
        let ab = SCNVector3(b.x - a.x, b.y - a.y, b.z - a.z)
        let bc = SCNVector3(c.x - b.x, c.y - b.y, c.z - b.z)
        let dot = ab.x * bc.x + ab.y * bc.y + ab.z * bc.z
        let magnitudeAB = sqrt(ab.x * ab.x + ab.y * ab.y + ab.z * ab.z)
        let magnitudeBC = sqrt(bc.x * bc.x + bc.y * bc.y + bc.z * bc.z)
        let magnitudeProduct = magnitudeAB * magnitudeBC
        let angle = acos(dot / magnitudeProduct)
        return CGFloat((angle * (180 / .pi)))
    }
}

extension SCNVector3 {
    
    var normalized: SCNVector3 {
        let len = sqrt(x * x + y * y + z * z)
        return SCNVector3(x: x / len, y: y / len, z: z / len)
    }
    
    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
        let x = self.x * matrix.m11 + self.y * matrix.m21 + self.z * matrix.m31 + matrix.m41
        let y = self.x * matrix.m12 + self.y * matrix.m22 + self.z * matrix.m32 + matrix.m42
        let z = self.x * matrix.m13 + self.y * matrix.m23 + self.z * matrix.m33 + matrix.m43
        return SCNVector3(x: x, y: y, z: z)
    }
}
