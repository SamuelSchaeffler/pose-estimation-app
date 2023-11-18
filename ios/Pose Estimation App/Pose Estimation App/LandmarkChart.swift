//
//  LandmarkChart.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 01.11.23.
//

import Foundation
import SwiftUI
import Charts

struct chartData: Identifiable, Hashable {
    let id = UUID()
    let landmarks: Float
    let timestamps: Int
}


//var chartDataArrays: ([Float], [Int]) = ([],[])
var dataList: [[chartData]] = [[], [], []]
var videoPointMarkTime: Int = 0
var videoPointMark1: Float = 0
var videoPointMark2: Float = 0
var videoPointMark3: Float = 0
var opacityPointMark1: Double = 0
var opacityPointMark2: Double = 0
var opacityPointMark3: Double = 0

struct LandmarkChart: View {
    
   let colors: [Color] = [.red, .blue, .green]
    
    var body: some View {
        
        Chart {
            
            ForEach(dataList[0], id: \.self) { series in
                LineMark(
                    x: .value("Kategorie", series.timestamps),
                    y: .value("Wert", series.landmarks),
                    series: .value("", "0")
                )
                .foregroundStyle(.red)
            }
            ForEach(dataList[1], id: \.self) { series in
                LineMark(
                    x: .value("Kategorie", series.timestamps),
                    y: .value("Wert", series.landmarks),
                    series: .value("", "1")
                )
                .foregroundStyle(.blue)
            }
            ForEach(dataList[2], id: \.self) { series in
                LineMark(
                    x: .value("Kategorie", series.timestamps),
                    y: .value("Wert", series.landmarks),
                    series: .value("", "2")
                )
                .foregroundStyle(.green)
            }
            
            PointMark(
                x: .value("Timestamp", videoPointMarkTime),
                y: .value("Bewegung", videoPointMark1)
            ).foregroundStyle(Color(red: 160, green: 0, blue: 0).opacity(opacityPointMark1))
            PointMark(
                x: .value("Timestamp", videoPointMarkTime),
                y: .value("Bewegung", videoPointMark2)
            ).foregroundStyle(Color(red: 0, green: 0, blue: 160).opacity(opacityPointMark2))
            PointMark(
                x: .value("Timestamp", videoPointMarkTime),
                y: .value("Bewegung", videoPointMark3)
            ).foregroundStyle(Color(red: 0, green: 160, blue: 0).opacity(opacityPointMark3))
            
        }

            
        
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel(position: .bottom, alignment: .center) {Text("Zeit (Millisekunden)")}
        .chartYAxisLabel(position: .leading, alignment: .center) {Text("Position (Millimeter)")}.background(.clear)
    }
    
}

