//
//  Filters.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 12.12.23.
//

import Foundation
import SceneKit

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



struct KalmanFilter {
    var q: Float // Prozessrauschen
    var r: Float // Messrauschen
    var x: Float // Geschätzter Wert
    var p: Float // Schätzfehler
    var k: Float // Kalman Gain

    init(q: Float, r: Float, initialP: Float, initialValue: Float) {
        self.q = q
        self.r = r
        self.x = initialValue
        self.p = initialP
        self.k = 0.0
    }

    mutating func update(measurement z: Float) {
        // Vorhersage-Update
        p = p + q

        // Mess-Update
        k = p / (p + r)
        x = x + k * (z - x)
        p = (1 - k) * p
    }
}

func applyKalmanFilter(to landmarks: [[SCNVector3]], q: Float, r: Float, initialP: Float) -> [[SCNVector3]] {
    guard !landmarks.isEmpty, let firstLandmark = landmarks.first, !firstLandmark.isEmpty else {
        return landmarks // Keine Daten zum Filtern vorhanden.
    }

    var filteredLandmarks = landmarks

    // Erstelle separate Filter für jede Koordinate jeder Landmarke.
    var xFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.x) }
    var yFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.y) }
    var zFilters = firstLandmark.map { KalmanFilter(q: q, r: r, initialP: initialP, initialValue: $0.z) }

    for i in 0..<landmarks.count {
        for j in 0..<landmarks[i].count {
            xFilters[j].update(measurement: landmarks[i][j].x)
            let filteredX = xFilters[j].x

            yFilters[j].update(measurement: landmarks[i][j].y)
            let filteredY = yFilters[j].x

            zFilters[j].update(measurement: landmarks[i][j].z)
            let filteredZ = zFilters[j].x

            filteredLandmarks[i][j] = SCNVector3(x: filteredX, y: filteredY, z: filteredZ)
        }
    }

    return filteredLandmarks
}


struct KalmanFilter3D {
    var q: Float // Prozessrauschen
    var r: Float // Messrauschen
    var x: SCNVector3 // Geschätzter Zustand (3D)
    var p: SCNVector3 // Schätzfehler (3D)
    var k: SCNVector3 // Kalman Gain (3D)

    init(q: Float, r: Float, initialP: Float, initialValue: SCNVector3) {
        self.q = q
        self.r = r
        self.x = initialValue
        self.p = SCNVector3(x: initialP, y: initialP, z: initialP)
        self.k = SCNVector3Zero
    }

    mutating func update(measurement z: SCNVector3) {
        // Vorhersage-Update
        p = SCNVector3(x: p.x + q, y: p.y + q, z: p.z + q)

        // Mess-Update
        k = SCNVector3(x: p.x / (p.x + r), y: p.y / (p.y + r), z: p.z / (p.z + r))
        x = SCNVector3(x: x.x + k.x * (z.x - x.x),
                       y: x.y + k.y * (z.y - x.y),
                       z: x.z + k.z * (z.z - x.z))
        p = SCNVector3(x: (1 - k.x) * p.x,
                       y: (1 - k.y) * p.y,
                       z: (1 - k.z) * p.z)
    }
}

func applyKalmanFilter3D(to landmarks: [[SCNVector3]], q: Float, r: Float, initialP: Float) -> [[SCNVector3]] {
    guard !landmarks.isEmpty else {
        return landmarks
    }

    var filteredLandmarks = landmarks
    var filter = KalmanFilter3D(q: q, r: r, initialP: initialP, initialValue: landmarks[0][0])

    for i in 0..<landmarks.count {
        for j in 0..<landmarks[i].count {
            filter.update(measurement: landmarks[i][j])
            filteredLandmarks[i][j] = filter.x
        }
    }

    return filteredLandmarks
}
