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

class landmarkData {
    
    static let shared = landmarkData()
    
    var landmarkDataList: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    var videoPointMarks: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var videoPointMarkTime: Int = 0
    var chartColors: [Color] = [.clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear]
    var fingerNumbers: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var angleDataList: [[chartAngleData]] = [[], [], [], [], []]
    var anglePointMarks: [Float] = [0, 0, 0, 0, 0]
    var angleChartColors: [UIColor] = [.clear, .clear, .clear, .clear, .clear]
}

class comparisonLandmarkData {
    
    static let shared = comparisonLandmarkData()
    
    var landmarkDataList1: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    var landmarkDataList2: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    var videoPointMarks1: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var videoPointMarks2: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var videoPointMarkTime1: Int = 0
    var videoPointMarkTime2: Int = 0
    var chartColors: [Color] = [.clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear]
    var fingerNumbers: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var angleDataList1: [[chartAngleData]] = [[], [], [], [], []]
    var angleDataList2: [[chartAngleData]] = [[], [], [], [], []]
    var anglePointMarks1: [Float] = [0, 0, 0, 0, 0]
    var anglePointMarks2: [Float] = [0, 0, 0, 0, 0]
    var angleChartColors: [UIColor] = [.clear, .clear, .clear, .clear, .clear]
}

struct LandmarkChart: View {
    let data = landmarkData.shared
    var body: some View {
        Chart {
            ForEach(Array(data.landmarkDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM\(index)", "\(index)")
                    ).foregroundStyle(data.chartColors[index])
                }
                PointMark(
                    x: .value("Timestamp", data.videoPointMarkTime),
                    y: .value("Bewegung", data.videoPointMarks[index])
                ).symbol {
                    Image(systemName: "\(data.fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((data.chartColors[index] == .clear ? .clear : .black), data.chartColors[index])
                    .font(.system(size: 12))
                }
            }
        }.chartLegend(.hidden)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Position (Millimeter)")}.background(.clear)
    }
}

struct AngleChart: View {
    let data = landmarkData.shared
    var body: some View {
        Chart {
            ForEach(Array(data.angleDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Winkel", series.angles),
                        series: .value("Angles\(index)", "\(index)")
                    ).foregroundStyle(Color(data.angleChartColors[index]))
                }
                PointMark(
                    x: .value("Timestamp", data.videoPointMarkTime),
                    y: .value("Winkel", data.anglePointMarks[index])
                ).foregroundStyle(Color(data.angleChartColors[index]))
            }
        }.chartLegend(.visible)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Winkel (°)")}.background(.clear)
    }
}

struct ComparisonLandmarkChart: View {
    let data = comparisonLandmarkData.shared
    var body: some View {
        Chart {
            ForEach(Array(data.landmarkDataList1.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM1\(index)", "1\(index)")
                    ).foregroundStyle(data.chartColors[index])
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                PointMark(
                    x: .value("Timestamp", data.videoPointMarkTime1),
                    y: .value("Bewegung", data.videoPointMarks1[index])
                ).symbol {
                    Image(systemName: "\(data.fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((data.chartColors[index] == .clear ? .clear : .black), data.chartColors[index])
                    .font(.system(size: 10))
                }
            }
            ForEach(Array(data.landmarkDataList2.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM2\(index)", "2\(index)")
                    ).foregroundStyle(data.chartColors[index])
                    .lineStyle(StrokeStyle(lineWidth: 2,dash: [3,3]))
                }
                PointMark(
                    x: .value("Timestamp", data.videoPointMarkTime2),
                    y: .value("Bewegung", data.videoPointMarks2[index])
                ).symbol {
                    Image(systemName: "\(data.fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((data.chartColors[index] == .clear ? .clear : .black), data.chartColors[index])
                    .font(.system(size: 10))
                }
            }
        }.chartLegend(.hidden)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Position (Millimeter)")}.background(.clear)
    }
}

struct ComparisonAngleChart: View {
    let data = comparisonLandmarkData.shared
    var body: some View {
        Chart {
            ForEach(Array(data.angleDataList1.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp1", series.timestamps),
                        y: .value("Winkel1", series.angles),
                        series: .value("Angles1\(index)", "1\(index)")
                    ).foregroundStyle(Color(data.angleChartColors[index]))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                PointMark(
                    x: .value("Timestamp1", data.videoPointMarkTime1),
                    y: .value("Winkel1", data.anglePointMarks1[index])
                ).foregroundStyle(Color(data.angleChartColors[index]))
            }
            ForEach(Array(data.angleDataList2.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp2", series.timestamps),
                        y: .value("Winkel2", series.angles),
                        series: .value("Angles2\(index)", "2\(index)")
                    ).foregroundStyle(Color(data.angleChartColors[index]))
                    .lineStyle(StrokeStyle(lineWidth: 2,dash: [3,3]))
                }
                PointMark(
                    x: .value("Timestamp2", data.videoPointMarkTime2),
                    y: .value("Winkel2", data.anglePointMarks2[index])
                ).foregroundStyle(Color(data.angleChartColors[index]))
            }
        }.chartLegend(.visible)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Winkel (°)")}.background(.clear)
    }
}
