//
//  DefaultTideService.swift
//  tides
//
//  Created by Zach Maillard on 9/19/26.
//

import Foundation
struct DefaultTideService : TideService {
    func getCurrentConditions(station: String, units: Units) async throws -> ConditionResult {
        let url = Self.buildURL(station: station, units: units, product: .waterlevel)
        return try await fetch(from: url, type: ConditionResult.self)
    }
    
    func getCurrentForecast(station: String, units: Units) async throws -> PredictionResult {
        let url = Self.buildURL(station: station, units: units, product: .predictions) 
        return try await fetch(from: url, type: PredictionResult.self)
    }
    
    static func buildURL(station: String, units: Units, product: RequestType, referenceDate: Date = Date()) -> String {
        let unitText = units == .english ? "english" : "metric"
        let application = "TidesiOS"
        switch product {
        case .predictions:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"

            let startDate = dateFormatter.string(from: referenceDate)
            let endDate = dateFormatter.string(from: referenceDate.addingTimeInterval(60*60*24*2))
            
            
            return "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(startDate)&end_date=\(endDate)&station=\(station)&product=predictions&datum=MLLW&time_zone=gmt&interval=hilo&units=\(unitText)&application=\(application)&format=json"
        case .waterlevel:
            return "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?date=latest&station=\(station)&product=water_level&datum=MLLW&time_zone=gmt&interval=hilo&units=\(unitText)&application=\(application)&format=json"
        }
    }
    
    func fetch<T: Decodable>(from URLString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: URLString) else {
            throw APIError.invalidURL
        }
        
        do {
            await URLSession.shared.flush()
            let (data, response) = try await  URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            
            return try JSONDecoder().decode(type, from: data)
            
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch let error as URLError {
            throw APIError.networkError(error)
        }
        
    }
    
}
