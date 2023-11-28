//
//  LandmarkChart.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 01.11.23.
//

import Foundation
import SwiftUI
import Charts

struct chartLandmarkData: Identifiable, Hashable {
    let id = UUID()
    let landmarks: Float
    let timestamps: Int
}

struct chartAngleData: Identifiable, Hashable {
    let id = UUID()
    let angles: Float
    let timestamps: Int
}


var landmarkDataList: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
var videoPointMarks: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var videoPointMarkTime: Int = 0
var chartColors: [Color] = [.clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear]
var fingerNumbers: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

var angleDataList: [[chartAngleData]] = [[], [], [], [], []]
var anglePointMarks: [Float] = [0, 0, 0, 0, 0]
var angleChartColors: [UIColor] = [.clear, .clear, .clear, .clear, .clear]//[.systemRed, .systemYellow, .magenta, .systemGreen, .systemOrange]



struct LandmarkChart: View {
    
    var body: some View {
        
        Chart {
            ForEach(Array(landmarkDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM\(index)", "\(index)")
                    )
                    .foregroundStyle(chartColors[index])
                }
                PointMark(
                    x: .value("Timestamp", videoPointMarkTime),
                    y: .value("Bewegung", videoPointMarks[index])
                )//.foregroundStyle(chartColors[index])
                .symbol {
                    Image(systemName: "\(fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((chartColors[index] == .clear ? .clear : .black), chartColors[index])
                    .font(.system(size: 12))
                }
            }
        }.chartLegend(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Position (Millimeter)")}.background(.clear)
    }
}

struct AngleChart: View {
    
    var body: some View {
        
        Chart {
            ForEach(Array(angleDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Winkel", series.angles),
                        series: .value("Angles\(index)", "\(index)")
                    )
                    .foregroundStyle(Color(angleChartColors[index]))
                }
                PointMark(
                    x: .value("Timestamp", videoPointMarkTime),
                    y: .value("Winkel", anglePointMarks[index])
                )
                .foregroundStyle(Color(angleChartColors[index]))
                
            }
        }.chartLegend(.visible)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Winkel (°)")}.background(.clear)
    }
}


