//
//  NavigatorTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

@MainActor
struct NavigatorTests {

    @Test("Deep link with settings host navigates to root and settings")
    func deepLinkToSettingsNavigatesToRootAndSettings() throws {
        let navigator = Navigator()
        let url = try #require(URL(string: "tides://settings"))

        navigator.handleDeepLink(url)

        #expect(navigator.path == [.root, .settings])
    }

    @Test("Deep link with no host navigates to root only")
    func deepLinkWithNoHostNavigatesToRootOnly() throws {
        let navigator = Navigator()
        let url = try #require(URL(string: "tides://"))

        navigator.handleDeepLink(url)

        #expect(navigator.path == [.root])
    }

    @Test("Deep link with unrecognized host still navigates to root only")
    func deepLinkWithUnknownHostNavigatesToRootOnly() throws {
        let navigator = Navigator()
        let url = try #require(URL(string: "tides://somewhere"))

        navigator.handleDeepLink(url)

        #expect(navigator.path == [.root])
    }

    @Test("Deep link with wrong scheme leaves path unchanged")
    func deepLinkWithWrongSchemeLeavesPathUnchanged() throws {
        let navigator = Navigator()
        navigator.push(.settings)
        let url = try #require(URL(string: "https://settings"))

        navigator.handleDeepLink(url)

        #expect(navigator.path == [.settings])
    }

    @Test("push appends a screen to the path")
    func pushAppendsScreen() {
        let navigator = Navigator()
        navigator.push(.root)
        navigator.push(.settings)

        #expect(navigator.path == [.root, .settings])
    }
}
