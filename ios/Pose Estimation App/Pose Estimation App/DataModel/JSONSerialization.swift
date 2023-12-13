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

func angleBetweenVectors1(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> CGFloat {
    let ab = SCNVector3(b.x - a.x, b.y - a.y, b.z - a.z)
    let bc = SCNVector3(c.x - b.x, c.y - b.y, c.z - b.z)
    let dot = ab.x * bc.x + ab.y * bc.y + ab.z * bc.z
    let magnitudeAB = sqrt(ab.x * ab.x + ab.y * ab.y + ab.z * ab.z)
    let magnitudeBC = sqrt(bc.x * bc.x + bc.y * bc.y + bc.z * bc.z)
    let magnitudeProduct = magnitudeAB * magnitudeBC
    let angle = acos(dot / magnitudeProduct)
    return CGFloat((angle * (180 / .pi)))
}

func angleBetweenVectors2(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> CGFloat {
    let ab = SCNVector3(b.x - a.x, b.y - a.y, b.z - a.z)
    let bc = SCNVector3(c.x - a.x, c.y - a.y, c.z - a.z)

    let normal = SCNVector3(
        x: ab.y * bc.z - ab.z * bc.y,
        y: ab.z * bc.x - ab.x * bc.z,
        z: ab.x * bc.y - ab.y * bc.x
    ).normalized

    let rotationAxis = SCNVector3CrossProduct(normal, SCNVector3(x: 0, y: 0, z: 1)).normalized
    let angle = acos(SCNVector3DotProduct(normal, SCNVector3(x: 0, y: 0, z: 1)))

    let rotationMatrix = SCNMatrix4MakeRotation(Float(angle), rotationAxis.x, rotationAxis.y, rotationAxis.z)

    let rotatedA = a.transformed(by: rotationMatrix)
    let rotatedB = b.transformed(by: rotationMatrix)
    let rotatedC = c.transformed(by: rotationMatrix)

    let newA = CGPoint(x: Double(rotatedA.x), y: Double(rotatedA.y))
    let newB = CGPoint(x: Double(rotatedB.x), y: Double(rotatedB.y))
    let newC = CGPoint(x: Double(rotatedC.x), y: Double(rotatedC.y))
    
    let steigungAB = calculateSlope(from: newA, to: newB)
    let steigungBC = calculateSlope(from: newB, to: newC)
    
    let schnittwinkel = atan(abs(((steigungBC - steigungAB) / (1 + steigungAB * steigungBC))))
    return CGFloat((schnittwinkel * (180 / .pi)))
}


func calculateSlope(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
    if point1.x == point2.x {
        return 0
    }
    return (point2.y - point1.y) / (point2.x - point1.x)
}

extension SCNVector3 {
    var normalized: SCNVector3 {
        let len = sqrt(x * x + y * y + z * z)
        return SCNVector3(x: x / len, y: y / len, z: z / len)
    }
}

func SCNVector3CrossProduct(_ v1: SCNVector3, _ v2: SCNVector3) -> SCNVector3 {
    return SCNVector3(
        x: v1.y * v2.z - v1.z * v2.y,
        y: v1.z * v2.x - v1.x * v2.z,
        z: v1.x * v2.y - v1.y * v2.x
    )
}

func SCNVector3DotProduct(_ v1: SCNVector3, _ v2: SCNVector3) -> CGFloat {
    return CGFloat(v1.x * v2.x + v1.y * v2.y + v1.z * v2.z)
}

extension SCNVector3 {
    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
        let x = self.x * matrix.m11 + self.y * matrix.m21 + self.z * matrix.m31 + matrix.m41
        let y = self.x * matrix.m12 + self.y * matrix.m22 + self.z * matrix.m32 + matrix.m42
        let z = self.x * matrix.m13 + self.y * matrix.m23 + self.z * matrix.m33 + matrix.m43
        return SCNVector3(x: x, y: y, z: z)
    }
}

