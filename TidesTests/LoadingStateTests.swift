//
//  LoadingStateTests.swift
//  TidesTests
//

import Testing
@testable import tides

struct LoadingStateTests {

    @Test("idle is not loading and has no error")
    func idleState() {
        let state: LoadingState<Int> = .idle
        #expect(state.isLoading == false)
        #expect(state.error == nil)
    }

    @Test("loading is loading and has no error")
    func loadingState() {
        let state: LoadingState<Int> = .loading
        #expect(state.isLoading == true)
        #expect(state.error == nil)
    }

    @Test("loaded is not loading and has no error")
    func loadedState() {
        let state: LoadingState<Int> = .loaded(42)
        #expect(state.isLoading == false)
        #expect(state.error == nil)
    }

    @Test("error is not loading and carries the message")
    func errorState() {
        let state: LoadingState<Int> = .error("boom")
        #expect(state.isLoading == false)
        #expect(state.error == "boom")
    }
}
