//
//  ScreenTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct ScreenTests {

    @Test("Screen id is the screen itself")
    func idIsSelf() {
        #expect(Screen.root.id == .root)
        #expect(Screen.settings.id == .settings)
    }

    @Test("Screen round-trips through Codable")
    func codableRoundTrip() throws {
        for screen: Screen in [.root, .settings] {
            let data = try JSONEncoder().encode(screen)
            let decoded = try JSONDecoder().decode(Screen.self, from: data)
            #expect(decoded == screen)
        }
    }
}
