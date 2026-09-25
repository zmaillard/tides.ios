//
//  TimeSeries.swift
//  tides
//
//  Created by Zach Maillard on 9/23/26.
//
import Foundation

protocol TimeSeries {
    var timeGMT: Date {get}
    var timeZoneLocal: TimeZone {get}
}

extension TimeSeries {
    func timeDisplayLocalTime(dateFormat: String) -> String {
        let format = DateFormatter()
        format.timeZone = self.timeZoneLocal
         
        format.dateFormat = dateFormat
         
        return format.string(from: self.timeGMT)
    }
}
