//
//  LandmarkChart.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 01.11.23.
//

import Foundation
import SwiftUI
import Charts

struct chartData: Identifiable {
    let id = UUID()
    let landmark: Float
    let timestamp: Int
}

var chartDataArrays: ([Float], [Int]) = ([],[])
var dataList: [chartData] = []

struct LandmarkChart: View {
    
    var list = dataList
    
    var body: some View {
        Chart(list) { chartData in
            LineMark(
                x: .value("Timestamp", chartData.timestamp),
                y: .value("Bewegung", chartData.landmark)
            ).foregroundStyle(.red)
        }.chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Position (Millimeter)")}
    }
    
}

