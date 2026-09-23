//
//  DefaultTideService.swift
//  tides
//
//  Created by Zach Maillard on 9/19/26.
//

import Foundation

struct DefaultTideService : TideService {
    func getCurrentForecast(station: String) async throws -> PredictionResult {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let curDate = Date()
        
        let startDate =  dateFormatter.string(from: curDate)
        let endDate =  dateFormatter.string(from: curDate.addingTimeInterval(60*60*24*2))
        
        let url = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(startDate)&end_date=\(endDate)&station=\(station)&product=predictions&datum=MLLW&time_zone=gmt&interval=hilo&units=english&application=DataAPI_Sample&format=json"
        
        
        return try await fetch(from: url, type: PredictionResult.self)
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
