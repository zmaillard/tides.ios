//
//  DefaultLocationManagerTests.swift
//  TidesTests
//

import CoreLocation
import Foundation
import Testing
@testable import tides

@MainActor
struct DefaultLocationManagerTests {

    @Test("Current location resolves with the most recent location update")
    func currentLocationResolvesFromUpdate() async throws {
        let (requests, requestContinuation) = AsyncStream<Void>.makeStream()
        let manager = DefaultLocationManager(requestLocation: { requestContinuation.yield(()) })
        let locationTask = Task { try await manager.currentLocation }
        var iterator = requests.makeAsyncIterator()
        _ = await iterator.next()

        let expectedLocation = CLLocation(latitude: 37.8, longitude: -122.4)
        manager.locationManager(
            manager.locationDataManager,
            didUpdateLocations: [
                CLLocation(latitude: 36, longitude: -121),
                expectedLocation
            ]
        )

        let location = try await locationTask.value
        #expect(location.coordinate.latitude == expectedLocation.coordinate.latitude)
        #expect(location.coordinate.longitude == expectedLocation.coordinate.longitude)
    }

    @Test("An empty location update fails the pending request")
    func emptyLocationUpdateThrowsLocationNotFound() async {
        let (requests, requestContinuation) = AsyncStream<Void>.makeStream()
        let manager = DefaultLocationManager(requestLocation: { requestContinuation.yield(()) })
        let locationTask = Task { try await manager.currentLocation }
        var iterator = requests.makeAsyncIterator()
        _ = await iterator.next()

        manager.locationManager(manager.locationDataManager, didUpdateLocations: [])

        do {
            _ = try await locationTask.value
            Issue.record("Expected an empty location update to throw")
        } catch let error as DefaultLocationManager.LocationManagerError {
            #expect(error == .locationNotFound)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Location failures are forwarded to the pending request")
    func locationFailureIsForwarded() async {
        let (requests, requestContinuation) = AsyncStream<Void>.makeStream()
        let manager = DefaultLocationManager(requestLocation: { requestContinuation.yield(()) })
        let locationTask = Task { try await manager.currentLocation }
        var iterator = requests.makeAsyncIterator()
        _ = await iterator.next()
        let expectedError = NSError(domain: "LocationTest", code: 42)

        manager.locationManager(manager.locationDataManager, didFailWithError: expectedError)

        do {
            _ = try await locationTask.value
            Issue.record("Expected the location request to fail")
        } catch let error as NSError {
            #expect(error.domain == expectedError.domain)
            #expect(error.code == expectedError.code)
        }
    }

    @Test("A newer location request fails the older pending request")
    func newerRequestReplacesPendingRequest() async throws {
        let (requests, requestContinuation) = AsyncStream<Void>.makeStream()
        let manager = DefaultLocationManager(requestLocation: { requestContinuation.yield(()) })
        var iterator = requests.makeAsyncIterator()
        let firstTask = Task { try await manager.currentLocation }
        _ = await iterator.next()
        let secondTask = Task { try await manager.currentLocation }
        _ = await iterator.next()

        do {
            _ = try await firstTask.value
            Issue.record("Expected the first request to be replaced")
        } catch let error as DefaultLocationManager.LocationManagerError {
            #expect(error == .replaceContinuation)
        }

        let expectedLocation = CLLocation(latitude: 40, longitude: -70)
        manager.locationManager(manager.locationDataManager, didUpdateLocations: [expectedLocation])
        let location = try await secondTask.value
        #expect(location.coordinate.latitude == expectedLocation.coordinate.latitude)
        #expect(location.coordinate.longitude == expectedLocation.coordinate.longitude)
    }

    @Test("Location manager requests authorization and location for supported statuses")
    func authorizationStatusesRequestExpectedActions() {
        var locationRequests = 0
        var authorizationRequests = 0
        let manager = DefaultLocationManager(
            requestLocation: { locationRequests += 1 },
            requestAuthorization: { authorizationRequests += 1 }
        )

        manager.updateAuthorizationStatus(.notDetermined)
        #expect(authorizationRequests == 1)

        manager.updateAuthorizationStatus(.authorizedWhenInUse)
        #expect(locationRequests == 1)
        #expect(manager.authorizationStatus == .authorizedWhenInUse)

        manager.updateAuthorizationStatus(.restricted)
        #expect(manager.authorizationStatus == .restricted)

        manager.updateAuthorizationStatus(.denied)
        #expect(authorizationRequests == 2)
        #expect(manager.authorizationStatus == .notDetermined)
    }
}
