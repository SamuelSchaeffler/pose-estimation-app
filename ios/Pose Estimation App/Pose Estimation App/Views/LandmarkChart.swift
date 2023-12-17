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
var angleChartColors: [UIColor] = [.clear, .clear, .clear, .clear, .clear]

var comparisonLandmarkDataList1: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
var comparisonLandmarkDataList2: [[chartLandmarkData]] = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
var comparisonVideo1PointMarks: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var comparisonVideo1PointMarkTime: Int = 0
var comparisonVideo2PointMarks: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var comparisonVideo2PointMarkTime: Int = 0

var comparisonAngleDataList1: [[chartAngleData]] = [[], [], [], [], []]
var comparisonAngleDataList2: [[chartAngleData]] = [[], [], [], [], []]
var comparisonAnglePointMarks1: [Float] = [0, 0, 0, 0, 0]
var comparisonAnglePointMarks2: [Float] = [0, 0, 0, 0, 0]

struct LandmarkChart: View {
    var body: some View {
        Chart {
            ForEach(Array(landmarkDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM\(index)", "\(index)")
                    ).foregroundStyle(chartColors[index])
                }
                PointMark(
                    x: .value("Timestamp", videoPointMarkTime),
                    y: .value("Bewegung", videoPointMarks[index])
                ).symbol {
                    Image(systemName: "\(fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((chartColors[index] == .clear ? .clear : .black), chartColors[index])
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
    var body: some View {
        Chart {
            ForEach(Array(angleDataList.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Winkel", series.angles),
                        series: .value("Angles\(index)", "\(index)")
                    ).foregroundStyle(Color(angleChartColors[index]))
                }
                PointMark(
                    x: .value("Timestamp", videoPointMarkTime),
                    y: .value("Winkel", anglePointMarks[index])
                ).foregroundStyle(Color(angleChartColors[index]))
            }
        }.chartLegend(.visible)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Winkel (°)")}.background(.clear)
    }
}

struct ComparisonLandmarkChart: View {
    var body: some View {
        Chart {
            ForEach(Array(comparisonLandmarkDataList1.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM1\(index)", "1\(index)")
                    ).foregroundStyle(chartColors[index])
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                PointMark(
                    x: .value("Timestamp", comparisonVideo1PointMarkTime),
                    y: .value("Bewegung", comparisonVideo1PointMarks[index])
                ).symbol {
                    Image(systemName: "\(fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((chartColors[index] == .clear ? .clear : .black), chartColors[index])
                    .font(.system(size: 10))
                }
            }
            ForEach(Array(comparisonLandmarkDataList2.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp", series.timestamps),
                        y: .value("Bewegung", series.landmarks),
                        series: .value("LM2\(index)", "2\(index)")
                    ).foregroundStyle(chartColors[index])
                    .lineStyle(StrokeStyle(lineWidth: 2,dash: [3,3]))
                }
                PointMark(
                    x: .value("Timestamp", comparisonVideo2PointMarkTime),
                    y: .value("Bewegung", comparisonVideo2PointMarks[index])
                ).symbol {
                    Image(systemName: "\(fingerNumbers[index]).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle((chartColors[index] == .clear ? .clear : .black), chartColors[index])
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
    var body: some View {
        Chart {
            ForEach(Array(comparisonAngleDataList1.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp1", series.timestamps),
                        y: .value("Winkel1", series.angles),
                        series: .value("Angles1\(index)", "1\(index)")
                    ).foregroundStyle(Color(angleChartColors[index]))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                PointMark(
                    x: .value("Timestamp1", comparisonVideo1PointMarkTime),
                    y: .value("Winkel1", comparisonAnglePointMarks1[index])
                ).foregroundStyle(Color(angleChartColors[index]))
            }
            ForEach(Array(comparisonAngleDataList2.enumerated()), id: \.element) { index, dataList in
                ForEach(dataList, id: \.self) { series in
                    LineMark(
                        x: .value("Timestamp2", series.timestamps),
                        y: .value("Winkel2", series.angles),
                        series: .value("Angles2\(index)", "2\(index)")
                    ).foregroundStyle(Color(angleChartColors[index]))
                    .lineStyle(StrokeStyle(lineWidth: 2,dash: [3,3]))
                }
                PointMark(
                    x: .value("Timestamp2", comparisonVideo2PointMarkTime),
                    y: .value("Winkel2", comparisonAnglePointMarks2[index])
                ).foregroundStyle(Color(angleChartColors[index]))
            }
        }.chartLegend(.visible)
        .chartYAxis {AxisMarks(position: .leading)}
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Winkel (°)")}.background(.clear)
    }
}
