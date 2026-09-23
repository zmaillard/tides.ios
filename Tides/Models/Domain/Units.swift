//
//  Units.swift
//  tides
//
//  Created by Zach Maillard on 9/21/26.
//
enum Units: String, CaseIterable, Codable, CustomStringConvertible {
    case metric
    case english
    
    var description: String {
        switch self {
        case .metric:
            return "Metric"
        case .english:
            return "English"
        }
    }
    
}
