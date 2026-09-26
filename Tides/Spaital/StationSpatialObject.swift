//
//  SpatialObject.swift
//  tides
//
//  Created by Zach Maillard on 9/24/26.
//
import RTree
import Foundation

struct StationSpatialObject: SpatialObject {
    
    typealias Point = Point2D
   
    let point: Point
    let stationId: String
    
    func minimumBoundingRectangle() -> BoundingRectangle<Point2D> {
        BoundingRectangle(lower: self.point, upper: self.point)
    }
    
    func distanceSquared(point: Point2D) -> Double {
        pow(point.x - self.point.x, 2) + pow(point.y - self.point.y, 2)
    }
    func contains(point: Point2D) -> Bool {
        return self.distanceSquared(point: point) <= Point.Scalar.zero
    }

}

extension StationSpatialObject: Equatable {
    static func == (lhs: StationSpatialObject, rhs: StationSpatialObject) -> Bool {
        lhs.point == rhs.point && lhs.stationId == rhs.stationId
    }
}
