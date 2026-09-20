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
        
        let url = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(startDate)&end_date=\(endDate)&station=\(station)&product=predictions&datum=MLLW&time_zone=lst_ldt&interval=hilo&units=english&application=DataAPI_Sample&format=json"
        
        
        return try await fetch(from: url, type: PredictionResult.self)
    }
    /*

     func fetchCountry(from URLString: String) async throws -> Country {
     return try await fetch(from: URLString, type: Country.self)
     }
     func fetchState(from URLString: String) async throws -> StateDetails {
     return try await fetch(from: URLString, type: StateDetails.self)
     }
     
     func fetchSignDetail(from URLString: String) async throws -> RoadSignDetails {
     return try await fetch(from: URLString, type: RoadSignDetails.self)
     }
    */
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
     
    /*
     func fetchStateSubdivision(from URLString: String) async throws -> StateSubdivision {
     return try await fetch(from: URLString, type: StateSubdivision.self)
     }
     
     func fetchSigns(type: SearchType) async throws -> [RoadSign] {
     guard let url = URL(string: "https://search.roadsign.pictures/multi-search") else {
     throw APIError.invalidURL
     }
     
     
     do {
     
     let parameters =  try type.query()
     
     let body = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
     
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.httpBody = body
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     request.setValue("Bearer \(Environment.searchApiKey)", forHTTPHeaderField: "Authorization")
     
     let (data, response) = try await  URLSession.shared.data(for: request)
     guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
     throw APIError.invalidResponse
     }
     
     let dataResp = try JSONDecoder().decode(SearchData.self, from: data)
     
     if dataResp.results.isEmpty {
     return []
     
     }
     return dataResp.results[0].hits
     
     } catch let error as DecodingError {
     throw APIError.decoding(error)
     } catch let error as URLError {
     throw APIError.networkError(error)
     }
     
     }
     */
}
