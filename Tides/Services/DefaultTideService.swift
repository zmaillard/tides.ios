//
//  DefaultTideService.swift
//  tides
//
//  Created by Zach Maillard on 9/19/26.
//

import Foundation

struct DefaultTideService : TideService {
    func getCurrentForecast(station: String) async throws -> PredictionResult {
        let url = Self.buildForecastURL(station: station)
        return try await fetch(from: url, type: PredictionResult.self)
    }

    /// Builds the NOAA tide predictions request URL for the given station, covering
    /// a two-day window starting at `referenceDate`. Pure function, no side effects.
    static func buildForecastURL(station: String, referenceDate: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let startDate = dateFormatter.string(from: referenceDate)
        let endDate = dateFormatter.string(from: referenceDate.addingTimeInterval(60*60*24*2))

        return "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(startDate)&end_date=\(endDate)&station=\(station)&product=predictions&datum=MLLW&time_zone=gmt&interval=hilo&units=english&application=DataAPI_Sample&format=json"
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
