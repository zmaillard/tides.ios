//
//  Station.swift
//  tides
//
//  Created by Zach Maillard on 9/19/26.
//
import SwiftData

@Model
final class Station {
    #Index([\Station.id], [\.region], [\.state])
    
    @Attribute(.unique) var id: String
    
    var timeZone:String
    var name: String
    var isTidal: Bool
    var state: String
    var greatLakes: Bool
    var region: String
    var tideType: String
    var latitude: Float
    var longitude: Float
    var observeDST: Bool
    var timeZoneOffset: Int
    
    init(timeZone: String, name: String, isTidal: Bool, state: String, greatLakes: Bool, region: String, tideType: String, id: String, latitude: Float, longitude: Float, observeDST: Bool, timeZoneOffset: Int) {
        self.timeZone = timeZone
        self.name = name
        self.isTidal = isTidal
        self.state = state
        self.greatLakes = greatLakes
        self.region = region
        self.tideType = tideType
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.observeDST = observeDST
        self.timeZoneOffset = timeZoneOffset
    }
    
}
