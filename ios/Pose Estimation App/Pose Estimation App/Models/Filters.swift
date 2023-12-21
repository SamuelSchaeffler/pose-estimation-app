//
//  Filters.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 12.12.23.
//

import Foundation
import SceneKit

class Filter {
    
    static let shared = Filter()
    
    var landmarkFilterStates = [false, false, false, false]
    var windowSizeMA: Int = 0
    var omegaCPT1: Float = 0
    var sampleTimePT1: Float = (1 / 10)
    var useFPSSampleTimePT1 = false
    var qKalman: Float = 0
    var rKalman: Float = 0
    var initialPKalman: Float = 0
    var landmarkShiftAmount: Int = 0

    func movingAverage(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
        let windowSize = windowSizeMA
        let vectorFunctions = VectorFunctions()
        print("Fenstergröße: \(windowSize)")
        var smoothedLandmarks = [[SCNVector3]]()
        for i in 0..<landmarks.count {
            var smoothedFrame = [SCNVector3]()
            for j in 0..<landmarks[i].count {
                var sum = SCNVector3(0, 0, 0)
                var count = 0
                for k in max(0, i - windowSize / 2)...min(landmarks.count - 1, i + windowSize / 2) {
                    sum = vectorFunctions.addVector(sum, landmarks[k][j])
                    count += 1
                }
                smoothedFrame.append(SCNVector3(sum.x / Float(count), sum.y / Float(count), sum.z / Float(count)))
            }
            smoothedLandmarks.append(smoothedFrame)
        }
        return smoothedLandmarks
    }

    func applyPT1Filter(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
        let omegaC = omegaCPT1
        let sampleTime = sampleTimePT1
        print("Gremzfrequenz: \(omegaC)")
        print("Abtastzeit: \(sampleTime)")
        var filteredLandmarks = landmarks
        let alpha = (2 - sampleTime * omegaC) / (2 + sampleTime * omegaC)
        let beta = sampleTime * omegaC / (2 + sampleTime * omegaC)
        for timeIndex in 1..<landmarks.count {
            for pointIndex in 0..<landmarks[timeIndex].count {
                let previous = filteredLandmarks[timeIndex - 1][pointIndex]
                let current = landmarks[timeIndex][pointIndex]
                let filteredX = alpha * previous.x + beta * (current.x + previous.x)
                let filteredY = alpha * previous.y + beta * (current.y + previous.y)
                let filteredZ = alpha * previous.z + beta * (current.z + previous.z)
                filteredLandmarks[timeIndex][pointIndex] = SCNVector3(x: filteredX, y: filteredY, z: filteredZ)
            }
        }
        return filteredLandmarks
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

    func applyKalmanFilter(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
        let q = qKalman
        let r = rKalman
        let initialP = initialPKalman
        print("Prozessrauschen: \(q)")
        print("Messrauschen: \(r)")
        print("anfänglicher Schätzfehler: \(initialP)")
        guard !landmarks.isEmpty, let firstLandmark = landmarks.first, !firstLandmark.isEmpty else {
            return landmarks
        }
        var filteredLandmarks = landmarks
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

    func shiftLandmarks(landmarks: [[SCNVector3]]) -> [[SCNVector3]] {
        var shiftAmount = landmarkShiftAmount
        print("Verschiebungswert: \(shiftAmount)")
        var shiftedLandmarks = landmarks
        if shiftAmount > 0 {
            for timeIndex in stride(from: landmarks.count - 1, through: 0, by: -1) {
                let shiftedIndex = max(timeIndex - shiftAmount, 0)
                shiftedLandmarks[timeIndex] = landmarks[shiftedIndex]
            }
        } else if shiftAmount < 0 {
            for timeIndex in 0..<landmarks.count {
                let shiftedIndex = min(timeIndex - shiftAmount, landmarks.count - 1)
                shiftedLandmarks[timeIndex] = landmarks[shiftedIndex]
            }
        }
        return shiftedLandmarks
    }
}
