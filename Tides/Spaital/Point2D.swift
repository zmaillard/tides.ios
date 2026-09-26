//
//  Point2D.swift
//  tides
//
//  Created by Zach Maillard on 9/24/26.
//
import RTree

struct Point2D: PointN {
    
    typealias Scalar = Double
    
    var x: Scalar
    var y: Scalar
    
    init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }
    
    func dimensions() -> Int {
        2
    }
    
    static func from(value: Double) -> Point2D {
        Point2D(x: value, y: value)
    }
    
    subscript(index: Int) -> Double {
        get {
            if index == 0 {
                return self.x
            } else {
                return self.y
            }
        }
        set(newValue) {
            if index == 0 {
                self.x = newValue
            } else {
                self.y = newValue
            }
        }
    }
}

extension Point2D: Equatable {
    static func == (lhs: Point2D, rhs: Point2D) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}
