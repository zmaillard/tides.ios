//
//  APIErrorTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct APIErrorTests {

    @Test("invalidURL has expected description")
    func invalidURLDescription() {
        #expect(APIError.invalidURL.errorDescription == "The URL is Invalid")
    }

    @Test("invalidResponse has expected description")
    func invalidResponseDescription() {
        #expect(APIError.invalidResponse.errorDescription == "Invalid response from server")
    }

    @Test("decoding error wraps the underlying error's description")
    func decodingErrorWrapsUnderlyingDescription() {
        let underlying = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "bad data")
        )
        let error = APIError.decoding(underlying)

        #expect(error.errorDescription == "Failed to decode response: \(underlying.localizedDescription)")
    }

    @Test("networkError wraps the underlying error's description")
    func networkErrorWrapsUnderlyingDescription() {
        let underlying = URLError(.notConnectedToInternet)
        let error = APIError.networkError(underlying)

        #expect(error.errorDescription == "Network error: \(underlying.localizedDescription)")
    }
}
